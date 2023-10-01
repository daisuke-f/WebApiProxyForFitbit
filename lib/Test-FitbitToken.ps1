#requires -Version 7.2

<#
.SYNOPSIS


.DESCRIPTION
This function is a wrapper around the Fitbit API to update the token using the refresh token.
See https://dev.fitbit.com/build/reference/web-api/authorization/introspect/ for more information.

.OUTPUTS
PSCustomObject

.NOTE
The output object should have the following properties:
- active
- scope
- client_id
- user_id
- token_type
- exp
- lat
#>
function Test-FitbitToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $AccessToken
    )

    $param = @{
        Method = 'Post'
        Uri = 'https://api.fitbit.com/1.1/oauth2/introspect'
        Authentication = 'OAuth'
        Token = $AccessToken | ConvertTo-SecureString -AsPlainText
        Body = @{ token = $AccessToken }
    }

    $resp = Invoke-WebRequest @param

    $json = $resp.Content | ConvertFrom-Json

    $json |
        Add-Member -MemberType NoteProperty -Name ExpirationDate -Value (([datetime]'1970-01-01').AddMilliseconds($json.exp)) -PassThru |
        Add-Member -MemberType NoteProperty -Name IssuedDate -Value (([datetime]'1970-01-01').AddMilliseconds($json.iat)) -PassThru |
        Write-Output
}