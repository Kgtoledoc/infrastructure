resource "aws_ecr_repository" "repo_a" {
  name = "app-a"
  force_delete = true
}

resource "aws_ecr_repository" "repo_b" {
  name = "app-b"
  force_delete = true
}