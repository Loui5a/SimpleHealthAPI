Write-Host "Perform Pester Smoke Tests..."
$pesterFile = './PesterTest/SmokeTestPester.ps1'
if (-not (Test-Path $pesterFile)) {
	Write-Error "Pester test file not found: $pesterFile"
	exit 2
}
Invoke-Pester -Script $pesterFile -Output Detailed *> .\build\test-results\pester.log
exit $LASTEXITCODE

