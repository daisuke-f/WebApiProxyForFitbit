using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $InputTokenBlob, $TriggerMetadata)

# Set-StrictMode -Version Latest

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$method = $Request.Method
$path = $Request.Params.path
$access_token = $InputTokenBlob.access_token
$body = $Request.Body

if(0 -le $Request.Url.IndexOf('?')) {
    $queryParam = $Request.Url.Substring($Request.Url.IndexOf('?'))
} else {
    $queryParam = ''
}

if($null -eq $path) {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = "Path is required"
    })
    return
}

if($null -eq $access_token) {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = "Access token is required. Call /api/InitTokenBlob first."
    })
    return
}

$param = @{
    Method = $method
    Uri = 'https://api.fitbit.com/{0}{1}' -f $path, $queryParam
    Authentication = 'OAuth'
    Token = $access_token | ConvertTo-SecureString -AsPlainText
    Body = $body
    SkipHttpErrorCheck = $true
}

$resp = Invoke-WebRequest @param

if($null -eq $resp) {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadGateway
        Body = "Upstream error"
    })
    return
}

if(400 -le $resp.StatusCode) {
    Write-Host "Upstream server returned an error. Request parameters:"
    Write-Host ($param | ConvertTo-Json)
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $resp.StatusCode
    Body = $resp.Content
})
