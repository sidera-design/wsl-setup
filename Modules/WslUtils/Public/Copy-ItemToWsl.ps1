function Copy-ItemToWsl {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)][string]$Source,  # Windows 側パス（ファイル/フォルダ）
    [Parameter(Mandatory)][string]$Destination, # WSL パス（例: ~/work）
    [string]$Distro = $null,
    [switch]$ConvertLF = $false,
    [switch]$SetExecutable = $false
  )

  # ディストロ名を解決
  $DistroName = Resolve-WslDistro $Distro 
  # WSLのパス名を解決（~や環境変数の展開）
  $wslDestination = wsl -d $DistroName -- bash -lc "echo $Destination"

  if (-not (Test-Path $Source)) {
    throw "コピー元 '$Source' が見つかりません。"
  }

  # コピー元ファイルの確認
  $resolved = [System.IO.Path]::GetFullPath($Source)
  $wslSourcePath = Convert-PathToWsl $resolved -Distro $DistroName
  $isFileSource = wsl.exe -d $DistroName -- bash -lc "test -f '$wslSourcePath' && echo 'True'"

  if ($ConvertLF -and ($isFileSource -ne "True")) {
    # 改行コード変換オプションはファイルコピー時のみ有効
    Throw "改行コード変換オプションはファイルコピー時のみ有効です。コピー元 '$Source' はフォルダです。"
  }
  if ($SetExecutable -and ($isFileSource -ne "True")) {
    # 実行権限設定オプションはファイルコピー時のみ有効
    Throw "実行権限設定オプションはファイルコピー時のみ有効です。コピー元 '$Source' はフォルダです。"
  }

  if ($PSCmdlet.ShouldProcess("${Source}", "Copy to ${DistroName}:${Destination}")) {
    # 親フォルダを取得
    if ($wslDestination.EndsWith("/")) {
      $parentDir = $wslDestination.TrimEnd("/")
    }
    else {
      $parentDir = Split-Path -Parent $wslDestination
    }
    $parentDir = wsl.exe -d $DistroName -- bash -lc "dirname '$wslDestination'"
    # 存在しなければ作成
    wsl.exe -d $DistroName -- bash -lc "test -d '$parentDir' || mkdir -p '$parentDir'"
    # コピー
    wsl.exe -d $DistroName -- bash -lc "cp -rf $wslSourcePath $wslDestination"

    if ($isFileSource -eq "True") {
      # コピー先のファイル名を取得
      $wslFileName = wsl.exe -d $DistroName -- bash -lc "test -d '$wslDestination' && echo '$($wslDestination.TrimEnd("/"))/$(Split-Path -Leaf $wslSourcePath)' || echo '$wslDestination'"

      if ($ConvertLF) {
        # 改行コードをLinux形式に変換
        wsl -d $DistroName -- bash -lc "sed -i 's/\r$//' '$wslFileName'"
        if ($LASTEXITCODE -ne 0) {
          throw "$wslFileName の改行コードの変換に失敗しました。"
        }
      }

      if ($SetExecutable) {
        # 実行権限の設定
        wsl -d $DistroName -- chmod +x "'$wslFileName'"
        if ($LASTEXITCODE -ne 0) {
          throw "WSL内のスクリプト '$wslFileName' の実行権限の設定に失敗しました。"
        }
      }
    }

    Write-Host "Copied to WSL ${DistroName}:${wslDestination} from $Source ($wslSourcePath)"
  }
}
