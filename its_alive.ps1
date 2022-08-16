$cfg = Get-Content "./config.json" | ConvertFrom-Json

$watch_requests = Import-Csv -Path $cfg.watch_file

function Send-Pushover {
    
    param (
        # The API key for Pushover
        [Parameter(Mandatory)]
        [string]
        $APIKey,

        # API URL
        [Parameter(Mandatory)]
        [string]
        $URL,

        # The API user identifier key.
        [Parameter(Mandatory)]
        [string]
        $APIUserKey,

        # Device name / type.
        [Parameter()]
        [string]
        $Device,

        # Title
        [Parameter(Mandatory)]
        [string]
        $Title,

        # Message
        [Parameter(Mandatory)]
        [string]
        $Message
    )
    
    $rest_params = @{
        Method = "Post"
        URI = "$URL"
        StatusCodeVariable = "scv"        
        Body = @{
            "token"     = $APIKey
            "user"      = $APIUserKey
            "device"    = $Device
            "title"     = $Title
            "message"   = $Message
        }
    }

    $rest_result = Invoke-RestMethod @rest_params
    Return $result
}

foreach ( $row in $watch_requests ) {
    if ( $row.Status -eq "Watching" ) {
        $result = ping $row.IP -c 1
        $code = $?
        if ( $code ) {
            $row.LastResult = "Alive"
            $row.Status = "Done"
            Send-Pushover -APIKey $cfg.api_key -APIUserKey $cfg.user_key -URL $cfg.api_url -Device "iphone" -Title "It's Alive!" -Message "$($row.Name) is alive and responding to pings!"
        }
        else {
            $row.LastResult = "Failed"
        }
    }
}

$watch_requests | Export-Csv -Path $cfg.watch_file -NoTypeInformation