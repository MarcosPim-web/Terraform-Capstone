param(
    [string]$StreamName = "realtime-data-platform-dev-stream",
    [int]$RecordCount = 100
)

Write-Host "Enviando $RecordCount eventos a $StreamName..."

for ($i = 1; $i -le $RecordCount; $i++) {
    $event = @{
        event_id  = [guid]::NewGuid().ToString()
        user_id   = "user-$($i % 20)"
        event_type = "page_view"
        timestamp = (Get-Date).ToUniversalTime().ToString("o")
    } | ConvertTo-Json -Compress

    $partitionKey = "user-$($i % 20)-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
    $tempFile = [System.IO.Path]::GetTempFileName()

    [System.IO.File]::WriteAllText(
        $tempFile,
        "$event`n",
        [System.Text.UTF8Encoding]::new($false)
    )

    aws kinesis put-record `
        --stream-name $StreamName `
        --partition-key $partitionKey `
        --data "fileb://$tempFile" `
        --region us-east-1 | Out-Null

    Remove-Item $tempFile
}

Write-Host "Se enviaron $RecordCount eventos correctamente."