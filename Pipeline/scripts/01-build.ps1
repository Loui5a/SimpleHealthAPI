$ErrorActionPreference = 'Stop'

Write-Host "Restoring dependencies..."
dotnet restore

Write-Host "Building solution..."
dotnet buildcd --configuration Release

Write-Host "Run unit tests..."
# Ensure test results directory exists and write TRX there so CI can upload them
New-Item -Path .\build\test-results -ItemType Directory -Force | Out-Null
dotnet test --configuration Release --logger "trx;LogFileName=TestResults.trx"  

Write-Host "Publishing application..."
dotnet publish ./CodingTestEverllence/CodingTestEverllence.csproj -c Release -o ./build/publish

Write-Host "Build completed successfully"
exit 0

