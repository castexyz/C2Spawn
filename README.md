## What is this?

A dirty Windows port of this project: https://github.com/maliciousgroup/C2_Automation with minor fixes and improvements for stuff that was not working for me :)

To know more you can check the amazing blog post here: https://blog.malicious.group/automating-c2-infrastructure-with-terraform-nebula-caddy-and-cobalt-strike

## What do I need to do?
- Download the project into C:\dev\
- Open the project with Pycharm and create a virtual env
- Download Terraform.exe and place into C:\dev\C2Spawn\.venv\Scripts
- Add your linode token and domain name into the file variables.tf
- Add linode DNS servers in your domain control panel
- Add your own cobaltstrike.zip server files into C:\dev\C2Spawn\templates\files
- Open the terminal in pycharm, move into C:\dev\C2Spawn\templates
- terraform.exe init
- terraform.exe apply
- Once the infra is up, on the operator machine run nebula C:\dev\C2Spawn\templates\configs\nebula\operator_start.ps1
- Connect to CS server at IP 192.18.100.200
