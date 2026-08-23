param(
    [string]$StreamName = "realtime-data-platform-dev-stream",
    [int]$RecordCount = 100
)

Write-Host "Enviando $RecordCount eventos de sensores a $StreamName..."

for ($i = 1; $i -le $RecordCount; $i++) {

    $sensorNumber = (($i - 1) % 5) + 1
    $sensorId = "sensor-{0:D2}" -f $sensorNumber

    $temperature = [math]::Round(
        (Get-Random -Minimum 1500 -Maximum 3501) / 100.0,
        2
    )

    $humidity = [math]::Round(
        (Get-Random -Minimum 3000 -Maximum 9001) / 100.0,
        2
    )

    $airQualityIndex = Get-Random -Minimum 20 -Maximum 151

    $event = [ordered]@{
        sensor_id         = $sensorId
        temperature       = $temperature
        humidity          = $humidity
        air_quality_index = $airQualityIndex
        timestamp         = (Get-Date).ToUniversalTime().ToString("o")
    } | ConvertTo-Json -Compress

    $partitionKey = $sensorId
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