param(
    [string]$StreamName = "realtime-data-platform-dev-stream",
    [int]$RecordCount = 100,
    [int]$DelayMilliseconds = 500
)

Write-Host "Enviando $RecordCount eventos de sensores a $StreamName..."

for ($i = 1; $i -le $RecordCount; $i++) {

    $sensorId = "sensor_$(Get-Random -Minimum 1 -Maximum 6)"

    $event = @{
        sensor_id         = $sensorId
        temperature       = [math]::Round((Get-Random -Minimum 1500 -Maximum 3501) / 100, 2)
        humidity          = [math]::Round((Get-Random -Minimum 3000 -Maximum 9001) / 100, 2)
        air_quality_index = Get-Random -Minimum 20 -Maximum 151
        timestamp         = (Get-Date).ToUniversalTime().ToString("o")
    } | ConvertTo-Json -Compress

    $tempFile = [System.IO.Path]::GetTempFileName()

    [System.IO.File]::WriteAllText(
        $tempFile,
        "$event`n",
        [System.Text.UTF8Encoding]::new($false)
    )

    aws kinesis put-record `
        --stream-name $StreamName `
        --partition-key $sensorId `
        --data "fileb://$tempFile" `
        --region us-east-1 | Out-Null

    Remove-Item $tempFile

    Write-Host "Enviado: $event"

    Start-Sleep -Milliseconds $DelayMilliseconds
}

Write-Host "Se enviaron $RecordCount eventos correctamente."

