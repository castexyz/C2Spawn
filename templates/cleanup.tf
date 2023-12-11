//the generated files during the build process are all deleted and directories removed.
resource "null_resource" "pre_setup" {
  provisioner "local-exec" {
    when = destroy
    command = <<-EOT
      Remove-Item certificates\* -Force
      Remove-Item keys\red* -Force
      Remove-Item -Path C:\dev\C2Spawn\.venv\Scripts\nebula\ -Recurse -Force
      Remove-Item -Path C:\dev\C2Spawn\.venv\Scripts\nebula* -Recurse -Force
    EOT
    interpreter = ["powershell", "-Command"]
  }
}