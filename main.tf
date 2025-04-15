provider "aws" {
  region  = var.region
  profile = "aws-dev"
}

module "networking" {
  source = "./modules/networking"
}

module "eks" {
  source             = "./modules/eks"
  eks_cluster_sg     = module.networking.eks_cluster_sg
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  cluster_name       = "cluster-image-processor"
}

module "ecr" {
  source = "./modules/ecr"
}

module "alb_controller" {
  source       = "./modules/alb_controller"
  cluster_name = module.eks.cluster_name
  region       = var.region
}

module "codebuild" {
  source         = "./modules/codebuild"
  region         = var.region
  connection_arn = var.connection_arn
  app_a_repo     = "https://github.com/Kgtoledoc/app_a.git"
  app_b_repo     = "https://github.com/Kgtoledoc/app_b.git"
  terraform_repo = "https://github.com/Kgtoledoc/infrastructure.git"
  app_a_ecr_url  = module.ecr.app_a_ecr_url
  app_b_ecr_url  = module.ecr.app_b_ecr_url
  cluster_name   = module.eks.cluster_name
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
    bucket         = "bucket-test-1234667"
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "test"
    encrypt        = true
    profile        = "default"
  }
}


