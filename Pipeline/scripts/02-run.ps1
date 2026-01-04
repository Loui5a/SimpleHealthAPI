Write-Host "Starting API..."

# Read pipeline config (ApiPort and UseHttps) or fall back to environment variables
$configPath = Join-Path (Resolve-Path ..\..).Path 'Pipeline\pipeline.config.json'
$port = $env:API_PORT
$useHttps = $env:API_HTTPS
if (-not $port -and (Test-Path $configPath)) {
	$cfg = Get-Content $configPath | ConvertFrom-Json
	$port = $cfg.ApiPort
	$useHttps = $cfg.UseHttps
}

if (-not $port) { $port = 5000 }
if (-not $useHttps) { $useHttps = $false }

if ($useHttps -eq $true -or $useHttps -eq 'true') {
	# In CI we avoid interactive trust operations. If running in CI, fall back to HTTP to keep the run non-interactive.
	if ($env:GITHUB_ACTIONS -or $env:CI) {
		Write-Host "CI environment detected; skipping interactive dev-certs trust. Using HTTP for CI runs."
		$url = "http://localhost:$port"
	}
	else {
		Write-Host "Ensuring developer HTTPS certificate is available (dotnet dev-certs https --trust)"
		dotnet dev-certs https --trust | Out-Null
		$url = "https://localhost:$port"
	}
}
else {
	$url = "http://localhost:$port"
}

Write-Host "Starting API on $url (silent mode: stdout/stderr -> build/logs)"

# Ensure output directories exist
$buildDir = Join-Path (Resolve-Path ..\..).Path 'build'
if (-not (Test-Path $buildDir)) { New-Item -ItemType Directory -Path $buildDir | Out-Null }
$logsDir = Join-Path $buildDir 'logs'
if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir | Out-Null }

$stdoutFile = Join-Path $logsDir 'api.stdout.log'
$stderrFile = Join-Path $logsDir 'api.stderr.log'

# Start the process hidden and redirect output to log files so it runs silently
$argList = @('run','--project','./CodingTestEverllence','--urls',$url)
$proc = Start-Process -FilePath dotnet -ArgumentList $argList -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile -WindowStyle Hidden -PassThru

# Persist PID so cleanup script can stop it
$pidFile = Join-Path $buildDir 'api.pid'
$proc.Id | Out-File -FilePath $pidFile -Encoding ascii
Write-Host "API started with PID $($proc.Id) (logs: $stdoutFile, $stderrFile)"