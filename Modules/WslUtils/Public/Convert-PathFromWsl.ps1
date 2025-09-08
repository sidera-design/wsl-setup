function Convert-PathFromWsl {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]$WslPath,
    [string]$Distro = $null
  )
  process {
    # ディストロ名を解決
    $DistroName = Resolve-WslDistro $Distro 

    $out = wsl.exe -d $DistroName -- bash -lc 'wslpath -w "'$WslPath'"' 2>$null
    if (-not $LASTEXITCODE -eq 0 -or -not $out) {
      throw "wslpath -w 変換に失敗: $WslPath"
    }
    $out.Trim()
  }
}
