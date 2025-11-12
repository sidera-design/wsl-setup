function Invoke-WslScript {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)][string]$Script, # WSL 内のスクリプトパス
    [string]$ScriptArgs = "",
    [string]$Destination = "/tmp/",
    [string]$Distro = $null,
    [switch]$UseSudo = $false
  )
  # ディストロ名を解決
  $DistroName = Resolve-WslDistro $Distro 

  if (-not (Test-Path $Script)) {
    throw "スクリプト '$Script' が見つかりません。"
  }

  $scriptName = Split-Path -Leaf $Script
  
  # WSL内でディレクトリ確認
  $resolvedPath = wsl -d $DistroName -- echo $Destination
  $destIsDir = wsl -d $DistroName -- bash -lc "test -d '$resolvedPath'"
  if ($destIsDir -or $resolvedPath.EndsWith("/")) {
    $wslDir = $resolvedPath.TrimEnd("/")
  }
  else {
    $wslDir = Split-Path -Parent $resolvedPath
  }
  $WslPath = "$wslDir/$scriptName"

  if (-not ($PSCmdlet.ShouldProcess("${Script}", "Execute as ${DistroName}:${WslPath}"))) {
    return 0
  }
  # WSLのディレクトリ作成
  if (-not (wsl -d $DistroName -- bash -lc "test -d '$wslDir'")) {
    wsl -d $DistroName -- bash -lc "mkdir -p '$wslDir'"
    if ($LASTEXITCODE -ne 0) {
      throw "WSL内のディレクトリ '$wslDir' の作成に失敗しました。"
    }
  }
  # スクリプトをWSLにコピー
  Copy-ItemToWsl -Source $Script -Destination $WslPath -Distro $DistroName -ConvertLF -SetExecutable

  # スクリプト実行
  Write-Host "Executing WSL script: ${DistroName}:${WslPath} $ScriptArgs"
  Write-Host ""
  if ($UseSudo) {
    # sudo で実行する場合、パスワード入力を求められる
    wsl -d $DistroName -- sudo bash -lc "$WslPath $ScriptArgs"
  }
  else {
    wsl -d $DistroName -- bash -lc "$WslPath $ScriptArgs"
  }
  if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    throw "WSL内のスクリプト '$WslPath' がエラー終了しました。Return code: $LASTEXITCODE"
  }
}
