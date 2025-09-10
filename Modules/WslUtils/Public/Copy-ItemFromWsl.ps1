function Copy-ItemFromWsl {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)][string]$Source,      # WSL 側パス
    [Parameter(Mandatory)][string]$Destination,  # Windows 側フォルダ
    [string]$Distro = $null
  )

  # ディストロ名を解決
  $DistroName = Resolve-WslDistro $Distro   
  # WSLのパス名を解決（~や環境変数の展開）
  $wslSource = wsl -d $DistroName -- bash -lc "echo $Source"


  if ($PSCmdlet.ShouldProcess("${DistroName}:${Source}", "Copy to $Destination")) {
    # 親フォルダを取得
    $parentDir = Split-Path -Parent $Destination
    # 存在しなければ作成
    if (-not (Test-Path $parentDir)) {
      New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
    }
    $wslDestPath = Convert-PathToWsl $Destination -Distro $DistroName
    wsl.exe -d $DistroName -- cp -rf $wslSource $wslDestPath
  }
  Write-Host "Copied to $Destination from WSL ${DistroName}:${Source}"
}
