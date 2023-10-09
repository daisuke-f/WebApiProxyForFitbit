# Input bindings are passed in via param block.
param($Timer, $InputTokenBlob, $TriggerMetadata)

. lib/Update-FitbitToken.ps1

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

if (-not $InputTokenBlob -or -not ($InputTokenBlob.refresh_token) -or -not ($InputTokenBlob.client_id)) {
    throw [Exception]::new("Blob or blob properties are missing! Initialization is required!")
}

Write-Host "Refreshing token..."

$resp = Update-FitbitToken -ClientId $InputTokenBlob.client_id -RefreshToken $InputTokenBlob.refresh_token

if($resp) {
    $access_token = $resp.access_token
    $refresh_token = $resp.refresh_token

    $InputTokenBlob.access_token = $access_token
    $InputTokenBlob.refresh_token = $refresh_token
    $InputTokenBlob.last_check = (Get-Date -Format 'yyyy-MM-dd HH:mm:ssZ')

    Push-OutputBinding -Name OutputTokenBlob -Value $InputTokenBlob

    Write-Host "Token refreshed!"
} else {
    throw [Exception]::new("Something went wrong while refreshing the token!")
}