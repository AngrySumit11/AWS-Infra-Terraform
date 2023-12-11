data "template_file" "shell-script" {
  template = file("${path.module}/cloud-init.sh")

  vars = {
    ENVIRONMENT = var.environment
  }
}

#data "template_file" "red-canary-shell-script" {
#  template = file("${path.module}/../../../common/red-canary/red-canary.sh")

#  vars = {
#    REGION = data.aws_region.current.name
#  }
#}
data "template_cloudinit_config" "cloud-init" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }
  #part {
  #  content_type = "text/x-shellscript"
  #  content      = data.template_file.red-canary-shell-script.rendered
  #}
}
