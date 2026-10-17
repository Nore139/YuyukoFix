@echo off
rem Build the 32-bit opengl32.dll proxy (needs Visual Studio 2022 with C++ tools and Python 3)
rem Set PYTHON to a python.exe if "python" is not on PATH.
cd /d "%~dp0"
if not defined PYTHON set "PYTHON=python"
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars32.bat" >nul || exit /b 1
"%PYTHON%" -I gen.py || exit /b 1
if not exist out mkdir out
cl /nologo /utf-8 /O2 /MT /W3 /LD /Fo:out\ /Fe:out\opengl32.dll hook.c stubs.c /link /DEF:opengl32.def /NOLOGO || exit /b 1
del out\*.obj out\*.exp 2>nul
echo BUILD OK
