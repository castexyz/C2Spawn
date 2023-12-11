/*
In order to setup a Nebula network, the host machine used to build the infrastructure will need to download the nebula binary,
generate a new CA certificate and then generate keys for each machine used in this build.
This can be done before any of the machines are created, so that I can move the specific key to each host in order to test and verify the network status.

To accomplish this I will be creating two new files to put in the src/templates directory. These files will be called setup.tf and cleanup.tf, and will be responsible for handling all pre-build and post-build operations to make sure the operator has a clean environment between every run.
Downloads the nebula binary and then proceeds to setup a new CA certificate, then generates a key for every machine connecting to the Nebula network.
It also contains two (2) commands to run the bash script generate_key.ps1
*/
resource "null_resource" "setup" {
  provisioner "local-exec" {
    command = <<-EOT
# Define variables
$nebulaUrl = "https://github.com/slackhq/nebula/releases/download/v1.8.0/nebula-windows-amd64.zip"
$nebulaTarPath = "C:\dev\C2Spawn\.venv\Scripts\nebula.zip"
$nebulaExtractPath = "C:\dev\C2Spawn\.venv\Scripts\nebula"

$nebulaUrlLin = "https://github.com/slackhq/nebula/releases/download/v1.8.0/nebula-linux-amd64.tar.gz"
$nebulaTarPathLin = "C:\dev\C2Spawn\.venv\Scripts\nebula-lin.tar.gz"
$nebulaExtractPathLin = "C:\dev\C2Spawn\.venv\Scripts\nebula-lin"

$keyGenerationScriptPath = "C:\dev\C2Spawn\templates\keys\generate_key.ps1"

# Check if the files already exist
if (-not (Test-Path -Path $nebulaTarPath)) {
    # Download Nebula zip for Windows
    Invoke-WebRequest -Uri $nebulaUrl -OutFile $nebulaTarPath
}

if (-not (Test-Path -Path $nebulaTarPathLin)) {
    # Download Nebula tarball for Linux
    Invoke-WebRequest -Uri $nebulaUrlLin -OutFile $nebulaTarPathLin
}

# Create Nebula directory
New-Item -ItemType Directory -Path $nebulaExtractPath
New-Item -ItemType Directory -Path $nebulaExtractPathLin

# Extract Nebula zip
Expand-Archive -Path $nebulaTarPath -DestinationPath $nebulaExtractPath
tar -xzvf $nebulaTarPathLin -C $nebulaExtractPathLin

# Grant execute permission to key generation script
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-ItemProperty -Path $keyGenerationScriptPath -Name "IsReadOnly" -Value $false

# Run key generation script
& $keyGenerationScriptPath

# Restore normal exec policy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Default

# Change to the certificates directory
cd C:\dev\C2Spawn\templates\certificates

# Run Nebula certification commands
C:\dev\C2Spawn\.venv\Scripts\nebula\nebula-cert.exe ca -name "Spawn, Inc"
C:\dev\C2Spawn\.venv\Scripts\nebula\nebula-cert.exe sign -name "lighthouse1" -ip "192.168.100.1/24"
C:\dev\C2Spawn\.venv\Scripts\nebula\nebula-cert.exe sign -name "edge-redirector-1" -ip "192.168.100.10/24" -groups "edge"
C:\dev\C2Spawn\.venv\Scripts\nebula\nebula-cert.exe sign -name "internal-redirector-1" -ip "192.168.100.110/24" -groups "internal"
C:\dev\C2Spawn\.venv\Scripts\nebula\nebula-cert.exe sign -name "team-server" -ip "192.168.100.200/24" -groups "team-server"
C:\dev\C2Spawn\.venv\Scripts\nebula\nebula-cert.exe sign -name "operator" -ip "192.168.100.250/24" -groups "operator"
    EOT
    interpreter = ["powershell", "-Command"]
  }
}