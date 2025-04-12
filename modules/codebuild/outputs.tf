output "app_a_build_project_name" {
  value = aws_codebuild_project.app_a.name
}

output "app_b_build_project_name" {
  value = aws_codebuild_project.app_b.name
}

output "terraform_build_project_name" {
  value = aws_codebuild_project.terraform.name
}