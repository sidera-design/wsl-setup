function Get-WslDefaultDistroName {
  $lxssKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss'
  if (-not (Test-Path $lxssKey)) { return $null }

  $defaultGuid = (Get-ItemProperty $lxssKey -Name DefaultDistribution -ErrorAction Stop).DefaultDistribution
  if (-not $defaultGuid) { return $null }

  $distroKey = Join-Path $lxssKey $defaultGuid
  if (-not (Test-Path $distroKey)) { return $null }

  # DistributionName は REG_SZ（.NET 経由で Unicode として取得され、文字化けしません）
  $name = (Get-ItemProperty $distroKey -Name DistributionName -ErrorAction Stop).DistributionName
  return $name
}
