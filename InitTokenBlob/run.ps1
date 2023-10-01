using namespace System.Net

# Input bindings are passed in via param block.
[CmdletBinding()]
param($Request, $TriggerMetadata)

. lib/Test-FitbitToken.ps1

$access_token = $Request.Body.access_token
$refresh_token = $Request.Body.refresh_token

# check if all required parameters are provided
if (-not $access_token -or -not $refresh_token) {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = "Missing required parameters!"
    })
    return
}

$resp = Test-FitbitToken -AccessToken $access_token

if (-not $resp) {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadGateway
        Body = "Something went wrong while checking the token!"
    })
    return
}

Write-Host $resp

if (-not $resp.active) {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = "Yout token is not active!"
    })
    return
}

$tokenBlob = @{
    access_token = $access_token
    refresh_token = $refresh_token
    client_id = $resp.client_id
    last_check = (Get-Date -Format 'yyyy-MM-dd HH:mm:ssZ')
}

Push-OutputBinding -Name OutputTokenBlob -Value $tokenBlob

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
})