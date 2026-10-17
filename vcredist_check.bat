@echo off
rem Checks the Visual C++ runtimes this game needs and installs missing ones
rem from Microsoft's official download links. Place it next to player.exe.
setlocal
set "VCCHK_SELF=%~f0"
set "VCCHK_ARGS=%*"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=[IO.File]::ReadAllText($env:VCCHK_SELF,[Text.Encoding]::UTF8); $i=$s.IndexOf('#'+'PS_START'); Invoke-Expression $s.Substring($i)"
echo.
pause
exit /b
#PS_START
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$GameDir = Split-Path -Parent $env:VCCHK_SELF
$TestMissing = $env:VCCHK_ARGS -match '/test-missing'   # pretend everything is missing (no install)
$DryRun = $TestMissing -or ($env:VCCHK_ARGS -match '/dry-run')

# ---------- messages (ja / zh / en) ----------
$lang = (Get-Culture).Name
$L = if ($lang -like 'ja*') { 'ja' } elseif ($lang -like 'zh*') { 'zh' } else { 'en' }
$M = @{
  title      = @{ ja='幽幽子大人食欲不振 起動チェック'; zh='幽幽子大人食欲不振 启动检查'; en='Yuyuko launch check' }
  noexe      = @{ ja='注意: このファイルは player.exe と同じフォルダに置いてください。'; zh='注意：请把本文件放在 player.exe 所在的文件夹中。'; en='Note: put this file in the same folder as player.exe.' }
  checking   = @{ ja='必要なファイルを確認しています...'; zh='正在检查所需文件...'; en='Checking required files...' }
  ok         = @{ ja='OK'; zh='OK'; en='OK' }
  missing    = @{ ja='不足'; zh='缺少'; en='MISSING' }
  old        = @{ ja='古い'; zh='版本过旧'; en='TOO OLD' }
  wrongarch  = @{ ja='注意: ゲームフォルダの {0} は64bit版です。削除するか32bit版に置き換えてください。'; zh='注意：游戏文件夹中的 {0} 是64位版本，请删除或换成32位版本。'; en='Warning: {0} in the game folder is 64-bit. Delete it or replace it with the 32-bit one.' }
  allok      = @{ ja='必要なファイルはすべて揃っています。起動できない場合は、別の原因です。'; zh='所需文件已全部齐全。如果仍无法启动，则是其他原因。'; en='All required files are present. If the game still does not start, the cause is something else.' }
  need       = @{ ja='次のものをインストールする必要があります（すべてMicrosoft公式・32bit版）:'; zh='需要安装以下组件（均为微软官方32位版本）：'; en='The following need to be installed (official Microsoft, 32-bit):' }
  ask        = @{ ja='今すぐダウンロードしてインストールしますか？ (Y/N)'; zh='现在下载并安装吗？(Y/N)'; en='Download and install them now? (Y/N)' }
  manual     = @{ ja='手動で入れる場合は、次のページの x86 版を使ってください:'; zh='如需手动安装，请使用以下页面中的 x86 版本：'; en='To install manually, use the x86 versions on this page:' }
  dl         = @{ ja='ダウンロード中: {0}'; zh='正在下载：{0}'; en='Downloading: {0}' }
  badsig     = @{ ja='署名を確認できなかったため中止しました: {0}'; zh='无法验证签名，已中止：{0}'; en='Signature check failed, skipped: {0}' }
  inst       = @{ ja='インストール中: {0}（許可を求める画面が出たら「はい」を押してください）'; zh='正在安装：{0}（如弹出权限确认，请点击“是”）'; en='Installing: {0} (click Yes if Windows asks for permission)' }
  instfail   = @{ ja='インストールに失敗しました: {0}（終了コード {1}）'; zh='安装失败：{0}（退出代码 {1}）'; en='Install failed: {0} (exit code {1})' }
  dlfail     = @{ ja='ダウンロードに失敗しました: {0}'; zh='下载失败：{0}'; en='Download failed: {0}' }
  recheck    = @{ ja='もう一度確認しています...'; zh='正在重新检查...'; en='Checking again...' }
  done       = @{ ja='完了しました。ゲームを起動してみてください。'; zh='完成。请尝试启动游戏。'; en='Done. Try starting the game.' }
  stillmiss  = @{ ja='まだ足りないものがあります。上のページから手動で入れてください。'; zh='仍有缺失的组件，请从上面的页面手动安装。'; en='Something is still missing. Please install it manually from the page above.' }
  reboot     = @{ ja='インストールは成功しましたが、PCの再起動が必要です。'; zh='安装成功，但需要重启电脑。'; en='Installed, but a restart is required.' }
  cancel     = @{ ja='インストールしませんでした。'; zh='未进行安装。'; en='Nothing was installed.' }
  dryrun     = @{ ja='（テストモード: 実際のインストールは行いません）'; zh='（测试模式：不会实际安装）'; en='(test mode: nothing will be installed)' }
}
function T($k) { $M[$k][$L] }

# ---------- what the game needs ----------
$ManualPage = 'https://learn.microsoft.com/cpp/windows/latest-supported-vc-redist'
$Packages = @(
  @{ Name='Visual C++ 2010 (x86)'; Dlls=@('msvcr100.dll'); MinVer=$null
     Url='https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe'; Args='/passive /norestart' },
  @{ Name='Visual C++ 2012 (x86)'; Dlls=@('msvcr110.dll'); MinVer=$null
     Url='https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe'; Args='/install /passive /norestart' },
  @{ Name='Visual C++ 2013 (x86)'; Dlls=@('msvcr120.dll','msvcp120.dll'); MinVer=$null
     Url='https://aka.ms/highdpimfc2013x86enu'; Args='/install /passive /norestart' },
  # player.exe links against the v14 runtime; uv.dll was built with 14.16, so require at least that
  @{ Name='Visual C++ 2015-2022 (x86)'; Dlls=@('msvcp140.dll','vcruntime140.dll','ucrtbase.dll'); MinVer=[version]'14.16.0.0'
     Url='https://aka.ms/vc14/vc_redist.x86.exe'; Args='/install /passive /norestart' }
)

$Is64 = [Environment]::Is64BitOperatingSystem
$SysDir = if ($Is64) { Join-Path $env:windir 'SysWOW64' } else { Join-Path $env:windir 'System32' }

function Get-PeMachine($path) {
  $fs = [IO.File]::OpenRead($path)
  try {
    $br = New-Object IO.BinaryReader($fs)
    $fs.Position = 0x3c; $pe = $br.ReadInt32()
    $fs.Position = $pe + 4; return $br.ReadUInt16()
  } finally { $fs.Close() }
}

# returns 'ok', 'missing' or 'old'
function Test-Dll($dll, $minVer) {
  if ($TestMissing) { return 'missing' }
  $local = Join-Path $GameDir $dll
  if ((Test-Path $local) -and (Get-PeMachine $local) -eq 0x8664) {
    Write-Host ('  ' + ((T 'wrongarch') -f $dll)) -ForegroundColor Yellow
  }
  $found = $null
  foreach ($p in @($local, (Join-Path $SysDir $dll))) {
    if ((Test-Path $p) -and (Get-PeMachine $p) -eq 0x14c) { $found = $p; break }
  }
  if (-not $found) { return 'missing' }
  if ($minVer) {
    $vi = (Get-Item $found).VersionInfo
    $v = [version]('{0}.{1}.{2}.{3}' -f $vi.FileMajorPart, $vi.FileMinorPart, $vi.FileBuildPart, $vi.FilePrivatePart)
    if ($dll -ne 'ucrtbase.dll' -and $v -lt $minVer) { return 'old' }
  }
  return 'ok'
}

function Check-All {
  $need = @()
  foreach ($pkg in $Packages) {
    Write-Host ''
    Write-Host ('  [' + $pkg.Name + ']')
    $bad = $false
    foreach ($d in $pkg.Dlls) {
      $st = Test-Dll $d $pkg.MinVer
      $label = switch ($st) { 'ok' { T 'ok' } 'missing' { T 'missing' } 'old' { T 'old' } }
      $color = if ($st -eq 'ok') { 'Green' } else { 'Red' }
      Write-Host ('    {0,-18} {1}' -f $d, $label) -ForegroundColor $color
      if ($st -ne 'ok') { $bad = $true }
    }
    if ($bad) { $need += $pkg }
  }
  return ,$need
}

function Install-Package($pkg) {
  $tmp = Join-Path $env:TEMP ('vcchk_' + [IO.Path]::GetRandomFileName() + '.exe')
  Write-Host ''
  Write-Host ((T 'dl') -f $pkg.Name)
  try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $pkg.Url -OutFile $tmp -UseBasicParsing
  } catch {
    Write-Host ((T 'dlfail') -f $pkg.Name) -ForegroundColor Red
    return $false
  }
  try {
    # only run the installer if it carries a valid Microsoft signature
    $sig = Get-AuthenticodeSignature $tmp
    if ($sig.Status -ne 'Valid' -or $sig.SignerCertificate.Subject -notmatch 'O=Microsoft Corporation') {
      Write-Host ((T 'badsig') -f $pkg.Name) -ForegroundColor Red
      return $false
    }
    if ($DryRun) { Write-Host ('  OK: ' + $sig.SignerCertificate.Subject) -ForegroundColor Green; return $true }
    Write-Host ((T 'inst') -f $pkg.Name)
    $p = Start-Process -FilePath $tmp -ArgumentList $pkg.Args -Verb RunAs -Wait -PassThru
    # 0 = ok, 3010 = ok but reboot needed, 1638 = a newer version is already installed
    switch ($p.ExitCode) {
      0     { return $true }
      1638  { return $true }
      3010  { Write-Host (T 'reboot') -ForegroundColor Yellow; return $true }
      default { Write-Host ((T 'instfail') -f $pkg.Name, $p.ExitCode) -ForegroundColor Red; return $false }
    }
  } catch {
    Write-Host ((T 'instfail') -f $pkg.Name, $_.Exception.Message) -ForegroundColor Red
    return $false
  } finally {
    Remove-Item $tmp -ErrorAction SilentlyContinue
  }
}

# ---------- main ----------
Write-Host '=============================================='
Write-Host ('  ' + (T 'title'))
Write-Host '=============================================='
if ($DryRun) { Write-Host (T 'dryrun') -ForegroundColor Yellow }
if (-not (Test-Path (Join-Path $GameDir 'player.exe'))) { Write-Host (T 'noexe') -ForegroundColor Yellow }
Write-Host ''
Write-Host (T 'checking')
$need = Check-All
Write-Host ''
if ($need.Count -eq 0) {
  Write-Host (T 'allok') -ForegroundColor Green
  return
}
Write-Host (T 'need') -ForegroundColor Yellow
foreach ($pkg in $need) { Write-Host ('  - ' + $pkg.Name) }
Write-Host ''
Write-Host (T 'manual')
Write-Host ('  ' + $ManualPage)
Write-Host ''
$ans = Read-Host (T 'ask')
if ($ans -notmatch '^[yY]') { Write-Host (T 'cancel'); return }
foreach ($pkg in $need) { [void](Install-Package $pkg) }
if ($DryRun) { return }
Write-Host ''
Write-Host (T 'recheck')
$need = Check-All
Write-Host ''
if ($need.Count -eq 0) { Write-Host (T 'done') -ForegroundColor Green }
else { Write-Host (T 'stillmiss') -ForegroundColor Red; Write-Host ('  ' + $ManualPage) }
