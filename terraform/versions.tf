terraform {
  required_version = ">= 1.14.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }

  # Remote state in S3
  backend "s3" {
    bucket         = "gemops-tfstate-457451526979"
    key            = "gemops/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "gemops-tfstate-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "gemops"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}