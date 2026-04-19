param(
  [string[]]$AllowedPorts = @('5173', '5174', '5175', '5176', '4173')
)

$ErrorActionPreference = 'Stop'

function Test-PortAvailable {
  param([int]$Port)

  $listeners = Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue
  return -not $listeners
}

$selectedPort = $null
foreach ($portText in $AllowedPorts) {
  $port = [int]$portText
  if (Test-PortAvailable -Port $port) {
    $selectedPort = $port
    break
  }
}

if (-not $selectedPort) {
  throw "No allowed Flutter web port is available. Tried: $($AllowedPorts -join ', ')"
}

Write-Host "Launching Flutter web on http://localhost:$selectedPort"
flutter run -d chrome --web-port $selectedPort --web-hostname localhost