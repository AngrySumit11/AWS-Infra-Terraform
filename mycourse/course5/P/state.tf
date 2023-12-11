provider "aws" {
  region  = "us-west-2"
  profile = "poc"
  default_tags {
    tags = var.common_tags
  }
}

terraform {
  required_version = "~> 0.14.4"
  backend "s3" {
    bucket         = "course1-terraform-backend"
    key            = "poc/poc/terraform.tfstate"
    region         = "us-west-2"
    profile        = "prod"
    dynamodb_table = "terraform-lock"
    encrypt        = true

  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.69.0"
    }
  }
}

