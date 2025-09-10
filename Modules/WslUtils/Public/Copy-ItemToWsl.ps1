function Copy-ItemToWsl {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)][string]$Source,  # Windows 側パス（ファイル/フォルダ）
    [Parameter(Mandatory)][string]$Destination, # WSL パス（例: ~/work）
    [string]$Distro = $null
  )

  # ディストロ名を解決
  $DistroName = Resolve-WslDistro $Distro 
  # WSLのパス名を解決（~や環境変数の展開）
  $wslDestination = wsl -d $DistroName -- bash -lc "echo $Destination"

  if (-not (Test-Path $Source)) {
    throw "コピー元 '$Source' が見つかりません。"
  }

  if ($PSCmdlet.ShouldProcess("${Source}", "Copy to ${DistroName}:${Destination}")) {
    # 親フォルダを取得
    $resolved = [System.IO.Path]::GetFullPath($Source)
    $parentDir = Split-Path -Parent $resolved
    # 存在しなければ作成
    if (-not (Test-Path $parentDir)) {
      $wslParentPath = Convert-PathToWsl $parentDir -Distro $DistroName
      wsl.exe -d $DistroName -- bash -lc "mkdir -p $wslParentPath"
    }
    $wslSourcePath = Convert-PathToWsl $resolved -Distro $DistroName
    wsl.exe -d $DistroName -- bash -lc "cp -rf $wslSourcePath $wslDestination"
  }
  Write-Host "Copied to WSL ${DistroName}:${Destination} from $Source"
}
