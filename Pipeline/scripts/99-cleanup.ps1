Get-Process dotnet | Where-Object { $_.Path -like "*CodingTestEverllence*" } | Stop-Process
