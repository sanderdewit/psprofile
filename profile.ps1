$FormatEnumerationLimit = -1 #don't cut off the response when retrieving objects
$PSDefaultParameterValues = @{
    'export-csv:NotypeInformation'=$true
    'export-csv:Encoding'='UTF8'
    'export-csv:delimiter'=';'
    'import-csv:delimiter'=';'
    'group-Object:NoElement'=$true
    'Install-Module:Scope' = 'CurrentUser'
}

function Prompt {
    Write-Host (Get-Date -Format "dd-MM HH:mm") -NoNewline
    try {
        $history = Get-History -ErrorAction Ignore -Count 1
        if ($history) {
            $ts = New-TimeSpan $history.StartExecutionTime  $history.EndExecutionTime
            switch ($ts) {
                { $_.totalminutes -gt 1 -and $_.totalminutes -lt 30 } {
                    Write-Host " [" -ForegroundColor Red -NoNewline
                    [decimal]$d = $_.TotalMinutes
                    '{0:f3}m' -f ($d) | Write-Host  -ForegroundColor Red -NoNewline
                    Write-Host "]" -ForegroundColor Red -NoNewline
                }
                { $_.totalminutes -le 1 -and $_.TotalSeconds -gt 1 } {
                    Write-Host " [" -ForegroundColor Yellow -NoNewline
                    [decimal]$d = $_.TotalSeconds
                    '{0:f3}s' -f ($d) | Write-Host  -ForegroundColor Yellow -NoNewline
                    Write-Host "[" -ForegroundColor Yellow -NoNewline
                }
                { $_.TotalSeconds -le 1 } {
                    [decimal]$d = $_.TotalMilliseconds
                    Write-Host " [" -ForegroundColor Green -NoNewline
                    '{0:f3}ms' -f ($d) | Write-Host  -ForegroundColor Green -NoNewline
                    Write-Host "]" -ForegroundColor Green -NoNewline
                }
                Default {
                    $_.Milliseconds | Write-Host  -ForegroundColor Gray -NoNewline
                }
            }
        }
    }
    catch { }
    Write-Host " $($pwd.path)" -NoNewLine
    "> "
}

Set-PSReadLineOption -AddToHistoryHandler { #prevent from saving credentials into history
    param([string]$line)

    $sensitive = "password|asplaintext|token|key|secret|credential"
    return ($line -notmatch $sensitive)
}

function Convert-AzureAdSidToObjectId {
    param([String] $ObjectId)

    $bytes = [Guid]::Parse($ObjectId).ToByteArray()
    $array = New-Object 'UInt32[]' 4

    [Buffer]::BlockCopy($bytes, 0, $array, 0, 16)
    $sid = "S-1-12-1-$array".Replace(' ', '-')

    return $sid
}
