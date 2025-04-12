provider "aws" {
  region = "us-west-2"
}

module "networking" {
  source = "./networking"
}

module "eks" {
  source     = "./eks"
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.subnet_ids
}

module "codebuild" {
  source        = "./codebuild"
  app_a_repo    = "https://github.com/your-repo/app-a.git"
  app_b_repo    = "https://github.com/your-repo/app-b.git"
  terraform_repo = "https://github.com/your-repo/terraform.git"
  app_a_ecr_url = module.eks.ecr_app_a_url
  app_b_ecr_url = module.eks.ecr_app_b_url
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.0.0"
  backend "s3" {
    bucket         = "mi-bucket-de-terraform"
    key            = "terraform/state"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}


