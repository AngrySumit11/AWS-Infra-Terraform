provider "aws" {
  region  = "us-west-2"
  profile = "course1-non-prod"
  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias   = "course1-non-prod-us-west-2"
  region  = "us-west-2"
  profile = "course1-non-prod"
  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias   = "course1-non-prod-us-east-1"
  region  = "us-east-1"
  profile = "course1-non-prod"
  default_tags {
    tags = var.common_tags
  }
}

terraform {
  required_version = "~> 0.14.4"
  backend "s3" {
    bucket         = "course1-course1-terraform-backend"
    key            = "course1—non-prod/dev/terraform.tfstate"
    region         = "us-west-2"
    profile        = "course1-prod"
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

