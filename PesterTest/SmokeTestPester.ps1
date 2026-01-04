Describe "API Smoke Tests" {
	$baseUrl = $null
	$healthEndpoint = $null

	BeforeAll {
		# read settings from environment variables or pipeline config
		$port = $env:API_PORT
		$useHttps = $env:API_HTTPS
		$configPath = Join-Path (Resolve-Path ..\).Path 'Pipeline\pipeline.config.json'
		if (-not $port -and (Test-Path $configPath)) {
			$cfg = Get-Content $configPath | ConvertFrom-Json
			$port = $cfg.ApiPort
			$useHttps = $cfg.UseHttps
		}
		if (-not $port) { $port = 5000 }
		if (-not $useHttps) { $useHttps = $false }
		$scheme = if ($useHttps -eq $true -or $useHttps -eq 'true') { 'https' } else { 'http' }
		$baseUrl = "${scheme}://localhost:$port"
		$healthEndpoint = "$baseUrl/health"
		$maxAttempts = 10
		$delaySeconds = 3
		$attempt = 1
		$apiReady = $false

		Write-Host "Waiting for API to become available at $healthEndpoint"
		$maxAttempts = 10
		$delaySeconds = 3
		$attempt = 1
		$apiReady = $false
		
		Write-Host "Waiting for API to become available at $healthEndpoint"
		
		while ($attempt -le $maxAttempts -and -not $apiReady) {
			try {
				$response = Invoke-WebRequest -Uri $healthEndpoint -Method Get -UseBasicParsing
				if ($response.StatusCode -eq 200) {
					Write-Host "API is up after $attempt attempt(s)"
					$apiReady = $true
					break
				}
			}
			catch {
				Write-Host "attempt $attempt : API not ready yet"
			}
			
			if (-not $apiReady) {
				Start-Sleep -Seconds $delaySeconds
			}
			$attempt++
		}
		if (-not $apiReady){
			throw "API did not become ready after $maxAttempts attempts"
		}
	}

	It "API root responds with 200 OK" { 
		$response = Invoke-WebRequest -Uri $healthEndpoint -Method Get -UseBasicParsing -ErrorAction Stop 
		$response.StatusCode | Should -Be 200 
		$response.Content | Should -Be "Healthy"
	}

}
