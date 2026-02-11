resource "null_resource" "vcs_task" {
  provisioner "local-exec" {
    command = "Hello, VCS Task!"
  }
}
