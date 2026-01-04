$ErrorActionPreference = 'Stop'

Write-Host "Restoring dependencies..."
dotnet restore

Write-Host "Building solution..."
dotnet build --configuration Release

Write-Host "Run unit tests..."
dotnet test --configuration Release --logger "trx"

Write-Host "Publishing application..."
dotnet publish ./CodingTestEverllence/CodingTestEverllence.csproj -c Release -o ./build/publish

Write-Host "Build completed successfully"
exit 0

