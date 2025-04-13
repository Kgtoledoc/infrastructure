output "alb_controller_role_arn" {
  description = "The ARN of the IAM role used by the AWS Load Balancer Controller"
  value       = aws_iam_role.alb_controller_role.arn
}