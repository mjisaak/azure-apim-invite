$users = Get-Content "users.json" | ConvertFrom-Json

$resourceGroup = 'my-apim-rg'
$apimName = 'my-apim-name'
$subscriptionId = 'my-subscription-id'

$users | ForEach-Object {
    $userId = $_.Email -replace '\W', '-'
    $uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.ApiManagement/service/$apimName/users/$($userId)?api-version=2019-12-01"

    try {
        $tmpFile = New-TemporaryFile

        @{
            properties = @{
                confirmation = "invite"
                firstName    = $_.FirstName
                lastName     = $_.LastName
                email        = $_.Email
                appType      = "developerPortal"
            }
        } | ConvertTo-Json -Compress | Out-File $tmpFile

        az rest --method put --uri $uri --body @$tmpFile    
    }
    finally {
        Remove-Item $tmpFile
    }
}
