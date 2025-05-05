
# === CONFIGURATION ===
$tenantId = "<YOUR_TENANT_ID>"
$clientId = "<YOUR_CLIENT_ID>"
$clientSecret = "<YOUR_CLIENT_SECRET>"
$attributeName = "extension_com_company_appstatus_zoomInstalled"
$logAnalyticsWorkspaceId = "<YOUR_LOG_ANALYTICS_WORKSPACE_ID>"
$logAnalyticsSharedKey = "<YOUR_LOG_ANALYTICS_SHARED_KEY>"
$logAnalyticsQuery = "ZoomInstalled_CL | where TimeGenerated > ago(1d) | project DeviceId, ZoomInstalled"

# === AUTHENTICATION ===
$body = @{
    grant_type    = "client_credentials"
    scope         = "https://graph.microsoft.com/.default"
    client_id     = $clientId
    client_secret = $clientSecret
}
$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Body $body
$accessToken = $tokenResponse.access_token
$headers = @{ Authorization = "Bearer $accessToken" }

# === LOG ANALYTICS QUERY ===
$logAnalyticsUri = "https://api.loganalytics.io/v1/workspaces/$logAnalyticsWorkspaceId/query"
$logAnalyticsBody = @{
    query = $logAnalyticsQuery
}
$logAnalyticsHeaders = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $logAnalyticsSharedKey"
}
$logAnalyticsResponse = Invoke-RestMethod -Uri $logAnalyticsUri -Method Post -Headers $logAnalyticsHeaders -Body ($logAnalyticsBody | ConvertTo-Json)
$logAnalyticsResults = $logAnalyticsResponse.tables[0].rows

# === PAGINATED DEVICE RETRIEVAL ===
$devices = @()
$uri = "https://graph.microsoft.com/v1.0/devices"
do {
    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    $devices += $response.value
    $uri = $response.'@odata.nextLink'
} while ($uri)

Write-Output "Total devices retrieved: $($devices.Count)"

# === LOOP THROUGH DEVICES ===
foreach ($device in $devices) {
    $deviceId = $device.id
    $deviceName = $device.displayName

    try {
        # Retrieve registry value from Log Analytics results
        $logAnalyticsResult = $logAnalyticsResults | Where-Object { $_.DeviceId -eq $deviceId }
        if ($logAnalyticsResult) {
            $attributeValue = $logAnalyticsResult.ZoomInstalled
        } else {
            $attributeValue = "Unknown"
        }

        $patchBody = @{
            $attributeName = $attributeValue
        } | ConvertTo-Json -Depth 3

        Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/devices/$deviceId" `
            -Headers (@{
                Authorization = "Bearer $accessToken"
                "Content-Type" = "application/json"
            }) -Method Patch -Body $patchBody

        Write-Output "Updated $deviceName ($deviceId) with $attributeName = $attributeValue"
    }
    catch {
        Write-Warning "Failed to update $deviceName ($deviceId): $_"
    }
}
