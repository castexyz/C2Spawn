# Define file path
$configFilePath = "C:\dev\C2Spawn\templates\configs\nebula\config-operator.yaml"

# Read content from the file
$configContent = Get-Content -Path $configFilePath -Raw

# Replace the string
$configContent = $configContent -replace 'LIGHTHOUSE_IP_ADDRESS', '172.233.60.94'

# Write the modified content back to the file
$configContent | Set-Content -Path $configFilePath

# Start the Nebula process
Start-Process -FilePath "C:\dev\C2Spawn\.venv\Scripts\nebula\nebula.exe" -ArgumentList "-config", "C:\dev\C2Spawn\templates\configs\nebula\config-operator.yaml" -NoNewWindow -Wait