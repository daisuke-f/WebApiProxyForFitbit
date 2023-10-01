#requires -Version 7.2

<#
.SYNOPSIS
Update the Fitbit token using the refresh token.

.DESCRIPTION
This function is a wrapper around the Fitbit API to update the token using the refresh token.
See https://dev.fitbit.com/build/reference/web-api/authorization/refresh-token/ for more information.

.OUTPUTS
PSCustomObject

.NOTE
The output object should have the following properties:
- access_token
- expires_in
- refresh_token
- token_type
- user_id
#>
function Update-FitbitToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $ClientId,
        [Parameter(Mandatory)]
        [string] $RefreshToken
    )

    $param = @{
        Method = 'Post'
        Uri = 'https://api.fitbit.com/oauth2/token'
        Body = @{
            grant_type = 'refresh_token'
            refresh_token = $RefreshToken
            client_id = $ClientId
        }
    }

    $resp = Invoke-WebRequest @param

    return $resp.Content | ConvertFrom-Json
}