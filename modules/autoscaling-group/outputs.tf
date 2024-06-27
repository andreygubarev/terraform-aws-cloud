output "autoscaling_group_arn" {
  value       = aws_autoscaling_group.this.arn
  description = "The ARN of the autoscaling group."
}

output "autoscaling_group_name" {
  value       = aws_autoscaling_group.this.name
  description = "The name of the autoscaling group."
}
