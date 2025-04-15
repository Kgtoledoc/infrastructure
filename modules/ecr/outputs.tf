output "app_a_ecr_url" {
 value = aws_ecr_repository.repo_a.repository_url
}

output "app_b_ecr_url" {
 value = aws_ecr_repository.repo_b.repository_url
}