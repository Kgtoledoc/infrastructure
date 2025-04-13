provider "aws" {
  region = var.region
}

module "networking" {
  source = "./networking"
}

module "eks" {
  source     = "./eks"
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.subnet_ids
  cluster_name = "cluster-image-processor"
}

module "alb_controller" {
  source       = "./alb_controller"
  cluster_name = module.eks.cluster_name
  region       = var.region
}

module "codebuild" {
  source        = "./codebuild"
  app_a_repo    = "https://github.com/Kgtoledoc/app-a.git"
  app_b_repo    = "https://github.com/Kgtoledoc/app-b.git"
  terraform_repo = "https://github.com/Kgtoledoc/infrastructure.git"
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
    bucket         = "bucket-state"
    key            = "terraform/state"
    region         = var.region
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}


