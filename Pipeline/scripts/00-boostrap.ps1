Write-Host "Bootstrapping Windows environment..."

# If running in CI (GITHUB_ACTIONS or CI), skip system-level installers to keep the run non-interactive
if (-not ($env:GITHUB_ACTIONS -or $env:CI)) {
    # Ensure winget is available
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "winget not found. Installing App Installer..."
        Invoke-WebRequest https://aka.ms/getwinget -OutFile winget.msixbundle
        Add-AppxPackage winget.msixbundle
    }

    # Update winget sources
    winget source update

    # Install or update PowerShell 7
    winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements --silent

    # Install .NET SDK (if your API needs it)
    Write-Host "Installing .NET SDK..."
    winget install --id Microsoft.DotNet.SDK.8 --accept-package-agreements --accept-source-agreements --silent
}

# Install Pester for the current user (non-interactive)
Write-Host "Installing Pester (current user)..."
if (-not (Get-Module -ListAvailable -Name Pester)) {
    Install-Module Pester -Force -SkipPublisherCheck -Scope CurrentUser -AllowClobber -ErrorAction SilentlyContinue
}

Write-Host "Bootstrap complete."
