function Convert-PathToWsl {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]$WindowsPath,
    [string]$Distro = $null
  )

  process {
    # ディストロ名を解決
    $DistroName = Resolve-WslDistro $Distro 

    $resolved = Resolve-Path $WindowsPath
    $out = wsl.exe -d $DistroName -- bash -c "wslpath -a '$resolved'" 2>$null
    if (-not $LASTEXITCODE -eq 0 -or -not $out) {
      throw "wslpath 変換に失敗: $WindowsPath (WSLディストロ名: $DistroName)"
    }
    $out.Trim()
  }
}
