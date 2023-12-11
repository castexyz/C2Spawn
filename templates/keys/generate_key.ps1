#Bash script to generate an operator SSH key when the infrastructure is building

# Get the current script path
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Check if the key file already exists
$keyFilePath = Join-Path $ScriptPath "red_nebula_rsa"
if (Test-Path $keyFilePath -PathType Leaf) {
    Write-Host "[WARNING] Keys seem to already exist. Skipping key generation"
    exit
}

# Generate SSH key using ssh-keygen
$sshKeygenCommand = "ssh-keygen -t ed25519 -f $($keyFilePath) -N '""'"
if (!(Invoke-Expression -Command $sshKeygenCommand)) {
    Write-Host "[ERROR] There was an error generating the SSH keys, check the code in generate_keys.ps1"
    exit
}