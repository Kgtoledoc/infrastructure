resource "aws_ecr_repository" "repo_a" {
  name = "app-a"
}

resource "aws_ecr_repository" "repo_b" {
  name = "app-b"
}