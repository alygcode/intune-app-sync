# Define registry path and value name
$regPath = "HKLM:\SOFTWARE\Company\AppStatus"
$regName = "ZoomInstalled"

# Define the expected app path
$appPath = "C:\Program Files (x86)\Zoom\bin\Zoom.exe"

# Create the registry key if it doesn't exist
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Check if the app is installed and write the result to the registry
if (Test-Path $appPath) {
    Set-ItemProperty -Path $regPath -Name $regName -Value "Yes"
} else {
    Set-ItemProperty -Path $regPath -Name $regName -Value "No"
}
