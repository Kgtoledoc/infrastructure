variable "app_a_repo" {
  description = "GitHub repository URL for app_a"
  type        = string
}

variable "app_b_repo" {
  description = "GitHub repository URL for app_b"
  type        = string
}

variable "terraform_repo" {
  description = "GitHub repository URL for Terraform configurations"
  type        = string
}

variable "app_a_ecr_url" {
  description = "ECR repository URL for app_a"
  type        = string
}

variable "app_b_ecr_url" {
  description = "ECR repository URL for app_b"
  type        = string
}

variable "artifact_bucket" {
  description = "S3 bucket for storing pipeline artifacts"
  type        = string
}

variable "connection_arn" {
  description = "ARN of the CodeStar connection for GitHub"
  type        = string
}