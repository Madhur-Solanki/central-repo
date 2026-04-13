# Quick start wrapper
if (Test-Path "$PSScriptRoot/client-bootstrap.ps1") {
  & "$PSScriptRoot/client-bootstrap.ps1"
} else { Write-Host 'client-bootstrap.ps1 not found.' -ForegroundColor Red }
