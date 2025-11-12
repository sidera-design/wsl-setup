$here = Split-Path -Parent $PSCommandPath
# Get-ChildItem "$here/Private/*.ps1" | ForEach-Object { . $_.FullName }
Get-ChildItem "$here/Public/*.ps1"  | ForEach-Object { . $_.FullName }
Export-ModuleMember -Function (Get-ChildItem "$here/Public/*.ps1" | ForEach-Object { $_.BaseName })
