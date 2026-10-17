/*
 * opengl32.dll proxy for 幽幽子大人食欲不振 (Pixel Game Maker MV / cocos2d-x 3.17.1)
 *
 * Some tileset images are taller than GL_MAX_TEXTURE_SIZE on many GPUs (16384 on Intel/AMD).
 * cocos2d-x refuses to create such textures, and the game stops on the next map.
 *
 * This proxy:
 *   - reports GL_MAX_TEXTURE_SIZE as at least 32768, so cocos2d-x tries to create the texture
 *   - downsizes any texture larger than the real limit inside glTexImage2D. Only the direction that is
 *     too large is shrunk (1/2, 1/4...), so a too-tall image keeps its full width. Box filter.
 *     Texture coordinates are normalized, so a smaller texture still maps to the same place.
 * Every other function jumps straight to the system opengl32.dll (stubs.c).
 *
 * Test switch: put "gl_proxy_test.txt" containing a number (e.g. 16384) next to this DLL
 * to pretend the GPU limit is that number.
 */
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#define GL_TEXTURE_2D 0x0DE1
#define GL_MAX_TEXTURE_SIZE 0x0D33
#define GL_UNPACK_ALIGNMENT 0x0CF5
#define GL_UNSIGNED_BYTE 0x1401
#define GL_ALPHA 0x1906
#define GL_RGB 0x1907
#define GL_RGBA 0x1908
#define GL_LUMINANCE 0x1909
#define GL_LUMINANCE_ALPHA 0x190A
#define GL_UNSIGNED_SHORT_4_4_4_4 0x8033
#define GL_UNSIGNED_SHORT_5_5_5_1 0x8034
#define GL_UNSIGNED_SHORT_5_6_5 0x8363
#define REPORTED_MAX 32768

#define REAL_COUNT 368
extern FARPROC g_real[REAL_COUNT];
extern const char *g_real_names[REAL_COUNT];

typedef void (WINAPI *PFN_TexImage2D)(UINT, int, int, int, int, int, UINT, UINT, const void *);
typedef void (WINAPI *PFN_GetIntegerv)(UINT, int *);
typedef void (WINAPI *PFN_PixelStorei)(UINT, int);

static PFN_TexImage2D real_TexImage2D;
static PFN_GetIntegerv real_GetIntegerv;
static PFN_PixelStorei real_PixelStorei;
static wchar_t g_dir[MAX_PATH];
static int g_limit;  /* real (or test) max texture size, 0 = not read yet */

static void log_line(const char *fmt, ...)
{
    wchar_t path[MAX_PATH];
    FILE *f;
    va_list ap;
    swprintf(path, MAX_PATH, L"%s\\gl_proxy_log.txt", g_dir);
    if (_wfopen_s(&f, path, L"a") || !f)
        return;
    va_start(ap, fmt);
    vfprintf(f, fmt, ap);
    va_end(ap);
    fputc('\n', f);
    fclose(f);
}

static int read_limit(void)
{
    int real = 0, test = 0;
    wchar_t path[MAX_PATH];
    FILE *f;
    real_GetIntegerv(GL_MAX_TEXTURE_SIZE, &real);
    swprintf(path, MAX_PATH, L"%s\\gl_proxy_test.txt", g_dir);
    if (!_wfopen_s(&f, path, L"r") && f) {
        if (fscanf_s(f, "%d", &test) != 1)
            test = 0;
        fclose(f);
    }
    log_line("GPU max texture size: %d", real);
    if (test > 0 && (real <= 0 || test < real)) {
        log_line("TEST MODE: pretending the limit is %d", test);
        return test;
    }
    return real > 0 ? real : 16384;
}

static int bytes_per_pixel(UINT format, UINT type)
{
    if (type == GL_UNSIGNED_BYTE) {
        switch (format) {
        case GL_RGBA: return 4;
        case GL_RGB: return 3;
        case GL_LUMINANCE_ALPHA: return 2;
        case GL_ALPHA:
        case GL_LUMINANCE: return 1;
        }
        return 0;
    }
    if (type == GL_UNSIGNED_SHORT_4_4_4_4 || type == GL_UNSIGNED_SHORT_5_5_5_1 || type == GL_UNSIGNED_SHORT_5_6_5)
        return 2;
    return 0;
}

void WINAPI hook_glGetIntegerv(UINT pname, int *params)
{
    real_GetIntegerv(pname, params);
    if (pname == GL_MAX_TEXTURE_SIZE && params && *params < REPORTED_MAX)
        *params = REPORTED_MAX;
}

void WINAPI hook_glTexImage2D(UINT target, int level, int internalformat, int width, int height,
                                                   int border, UINT format, UINT type, const void *pixels)
{
    int bpp, fx, fy, nw, nh, align = 4, x, y, c, dx, dy;
    size_t src_stride;
    const unsigned char *src = pixels;
    unsigned char *dst;

    if (!g_limit)
        g_limit = read_limit();
    if (target != GL_TEXTURE_2D || level != 0 || (width <= g_limit && height <= g_limit)) {
        real_TexImage2D(target, level, internalformat, width, height, border, format, type, pixels);
        return;
    }
    bpp = bytes_per_pixel(format, type);
    if (!pixels || !bpp) {
        log_line("SKIP %dx%d (format 0x%X type 0x%X, pixels %s)", width, height, format, type, pixels ? "set" : "NULL");
        real_TexImage2D(target, level, internalformat, width, height, border, format, type, pixels);
        return;
    }

    for (fx = 1; (width + fx - 1) / fx > g_limit; fx *= 2)
        ;
    for (fy = 1; (height + fy - 1) / fy > g_limit; fy *= 2)
        ;
    nw = (width + fx - 1) / fx;
    nh = (height + fy - 1) / fy;
    real_GetIntegerv(GL_UNPACK_ALIGNMENT, &align);
    if (align < 1)
        align = 1;
    src_stride = ((size_t)width * bpp + align - 1) / align * align;
    dst = malloc((size_t)nw * nh * bpp);
    if (!dst) {
        log_line("OUT OF MEMORY for %dx%d", width, height);
        real_TexImage2D(target, level, internalformat, width, height, border, format, type, pixels);
        return;
    }

    for (y = 0; y < nh; y++) {
        for (x = 0; x < nw; x++) {
            unsigned char *out = dst + ((size_t)y * nw + x) * bpp;
            if (type != GL_UNSIGNED_BYTE) {
                /* packed 16-bit formats: take the top-left pixel of the block */
                const unsigned char *in = src + (size_t)y * fy * src_stride + (size_t)x * fx * bpp;
                out[0] = in[0];
                out[1] = in[1];
                continue;
            }
            for (c = 0; c < bpp; c++) {
                unsigned sum = 0, n = 0;
                for (dy = 0; dy < fy && y * fy + dy < height; dy++)
                    for (dx = 0; dx < fx && x * fx + dx < width; dx++, n++)
                        sum += src[(size_t)(y * fy + dy) * src_stride + (size_t)(x * fx + dx) * bpp + c];
                out[c] = (unsigned char)((sum + n / 2) / n);
            }
        }
    }

    real_PixelStorei(GL_UNPACK_ALIGNMENT, 1);
    real_TexImage2D(target, level, internalformat, nw, nh, border, format, type, dst);
    real_PixelStorei(GL_UNPACK_ALIGNMENT, align);
    free(dst);
    log_line("downsized %dx%d -> %dx%d (width 1/%d, height 1/%d)", width, height, nw, nh, fx, fy);
}

static FARPROC find_real(const char *name)
{
    int i;
    for (i = 0; i < REAL_COUNT; i++)
        if (!strcmp(g_real_names[i], name))
            return g_real[i];
    return NULL;
}

BOOL WINAPI DllMain(HINSTANCE self, DWORD reason, LPVOID reserved)
{
    wchar_t path[MAX_PATH], *slash;
    HMODULE sys;
    int i;
    (void)reserved;
    if (reason != DLL_PROCESS_ATTACH)
        return TRUE;
    DisableThreadLibraryCalls(self);

    GetModuleFileNameW(self, g_dir, MAX_PATH);
    slash = wcsrchr(g_dir, L'\\');
    if (slash)
        *slash = 0;

    GetSystemDirectoryW(path, MAX_PATH);
    wcscat_s(path, MAX_PATH, L"\\opengl32.dll");
    sys = LoadLibraryW(path);
    if (!sys) {
        log_line("FAILED to load the system opengl32.dll");
        return FALSE;
    }
    for (i = 0; i < REAL_COUNT; i++)
        g_real[i] = GetProcAddress(sys, g_real_names[i]);
    real_TexImage2D = (PFN_TexImage2D)find_real("glTexImage2D");
    real_GetIntegerv = (PFN_GetIntegerv)find_real("glGetIntegerv");
    real_PixelStorei = (PFN_PixelStorei)find_real("glPixelStorei");

    {
        wchar_t logpath[MAX_PATH];
        FILE *f;
        swprintf(logpath, MAX_PATH, L"%s\\gl_proxy_log.txt", g_dir);
        if (!_wfopen_s(&f, logpath, L"w") && f)
            fclose(f);  /* start a fresh log each launch */
    }
    log_line("gl_proxy loaded");
    return TRUE;
}
