# Builds release\YuyukoFix_v<ver>.zip from gl_proxy\out\opengl32.dll, the checker, the docs and the proxy source.
# Build the DLL first with gl_proxy\build.bat.
param([string]$Version = '1.0')
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$name = "YuyukoFix_v$Version"
$stage = Join-Path $root "release\$name"
$zip = Join-Path $root "release\$name.zip"

if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
if (Test-Path $zip) { Remove-Item $zip -Force }
New-Item -ItemType Directory -Force "$stage\source" | Out-Null

# text files: CRLF; README gets a UTF-8 BOM so every Notepad shows it correctly
function Copy-Text($src, $dst, [bool]$bom) {
  $t = [IO.File]::ReadAllText($src, [Text.Encoding]::UTF8) -replace "`r?`n", "`r`n"
  [IO.File]::WriteAllText($dst, $t, (New-Object Text.UTF8Encoding($bom)))
}
Copy-Text "$root\dist\README.txt" "$stage\README.txt" $true
Copy-Text "$root\LICENSE" "$stage\LICENSE.txt" $false
Copy-Text "$root\vcredist_check.bat" "$stage\vcredist_check.bat" $false
Copy-Item "$root\gl_proxy\out\opengl32.dll" "$stage\opengl32.dll"
foreach ($f in 'hook.c', 'stubs.c', 'gen.py', 'exports.txt', 'opengl32.def', 'build.bat') {
  Copy-Item "$root\gl_proxy\$f" "$stage\source\$f"
}

Compress-Archive -Path $stage -DestinationPath $zip
Get-ChildItem $stage -Recurse -File | ForEach-Object {
  '{0,-28} {1,8}  {2}' -f $_.FullName.Substring($stage.Length + 1), $_.Length, (Get-FileHash $_.FullName -Algorithm SHA256).Hash.Substring(0, 16)
}
"zip: $zip  ($((Get-Item $zip).Length) bytes)"
