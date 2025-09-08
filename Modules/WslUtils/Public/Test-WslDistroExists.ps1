function Test-WslDistroExists {
  param([Parameter(Mandatory)][string]$Name)
  $list = wsl.exe -l -q 2>$null
  return $list -contains $Name
}