resource "aws_codebuild_project" "app_a" {
  name         = "app-a-build"
  service_role = aws_iam_role.codebuild_role.arn
  source {
    type            = "GITHUB"
    location        = var.app_a_repo
    buildspec       = "buildspec.yml"
    git_clone_depth = 1
  }
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true
    environment_variable {
      name  = "ECR_REPO_URL"
      value = var.app_a_ecr_url
    }
    environment_variable {
      name  = "CLUSTER_NAME"
      value = var.cluster_name
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name = "EKS_KUBECTL_ROLE_ARN"
      value = aws_iam_role.codebuild_role.arn
    }
  }
}

resource "aws_codebuild_project" "app_b" {
  name         = "app-b-build"
  service_role = aws_iam_role.codebuild_role.arn
  source {
    type            = "GITHUB"
    location        = var.app_b_repo
    buildspec       = "buildspec.yml"
    git_clone_depth = 1
  }
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true
    environment_variable {
      name  = "ECR_REPO_URL"
      value = var.app_b_ecr_url
    }
    environment_variable {
      name  = "CLUSTER_NAME"
      value = var.cluster_name
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name = "EKS_KUBECTL_ROLE_ARN"
      value = aws_iam_role.codebuild_role.arn
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "EksCodeBuildKubectlRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::291247178008:role/EksCodeBuildKubectlRole"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "eks_access_policy" {
  name        = "EksAccessPolicy"
  description = "Permisos para que CodeBuild interactúe con EKS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "eks:ListFargateProfiles",
          "eks:DescribeFargateProfile",
          "eks:ListUpdates",
          "eks:DescribeUpdate",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:CreateNodegroup",
          "eks:DeleteNodegroup",
          "eks:TagResource",
          "eks:UntagResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = "arn:aws:iam::291247178008:role/EksCodeBuildKubectlRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_policy_custom" {
  name = "codebuild-policy-custom"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.pipeline_artifacts.bucket}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection",
          "codestar-connections:GetConnection",
          "codestar-connections:GetConnectionToken",
          "codeconnections:UseConnection",
          "codeconnections:GetConnection",
          "codeconnections:GetConnectionToken",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "appconfig:StartDeployment",
          "appconfig:GetDeployment",
          "appconfig:StopDeployment"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetDeployment",
          "codedeploy:RegisterApplicationRevision",
          "codeconnections:*",
          "codepipeline:*",
          "logs:*",
          "eks:*",
          "ecr:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:CreateChangeSet",
          "cloudformation:DescribeChangeSet",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:DescribeStacks",
          "cloudformation:SetStackPolicy",
          "cloudformation:ValidateTemplate"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = [
              "cloudformation.amazonaws.com",
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com",
              "eks.amazonaws.com",
              "lambda.amazonaws.com",
              "codebuild.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_access_policy" {
  role = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.eks_access_policy.arn
  
}

resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "codebuild_k8s_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "codebuild_s3_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_eks_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}



resource "aws_codebuild_project" "terraform" {
  name         = "terraform-build"
  service_role = aws_iam_role.codebuild_role.arn
  source {
    type            = "GITHUB"
    location        = var.terraform_repo
    buildspec       = "buildspec.yml"
    git_clone_depth = 1
  }
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.pipeline_artifacts.bucket}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection",
          "codestar-connections:GetConnection",
          "codestar-connections:GetConnectionToken",
          "codeconnections:UseConnection",
          "codeconnections:GetConnection",
          "codeconnections:GetConnectionToken",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "appconfig:StartDeployment",
          "appconfig:GetDeployment",
          "appconfig:StopDeployment"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetDeployment",
          "codedeploy:RegisterApplicationRevision",
          "codeconnections:*",
          "codepipeline:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:CreateChangeSet",
          "cloudformation:DescribeChangeSet",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:DescribeStacks",
          "cloudformation:SetStackPolicy",
          "cloudformation:ValidateTemplate"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = [
              "cloudformation.amazonaws.com",
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com",
              "eks.amazonaws.com",
              "lambda.amazonaws.com",
              "codebuild.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# S3 artifact bucket
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "image-processor-pipeline-artifacts"
}

# Codepipeline app a
resource "aws_codepipeline" "app_a_pipeline" {
  name     = "app-a-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.connection_arn
        FullRepositoryId = "Kgtoledoc/app_a"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.app_a.name
      }
    }
  }

}


# Codepipeline app b
resource "aws_codepipeline" "app_b_pipeline" {
  name     = "app-b-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.connection_arn
        FullRepositoryId = "Kgtoledoc/app_b"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.app_b.name
      }
    }
  }

}

resource "aws_codepipeline" "infra_pipeline" {
  name     = "infra-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.connection_arn
        FullRepositoryId = "Kgtoledoc/infrastructure"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform.name
      }
    }
  }
}