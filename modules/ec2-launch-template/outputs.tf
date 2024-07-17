output "instance_launch_template" {
  value = {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }
  description = "EC2 instance launch template"
}
