terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.69.0"
    }
  }
  backend "s3" {
    bucket         = "course-datadog-terraform-backend"
    key            = "course1-prod/prod/terraform.tfstate"
    region         = "us-west-2"
    profile        = "course3-prod"
    dynamodb_table = "terraform-lock"
    encrypt        = true

  }
}

# Configure the Datadog provider
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  alias   = "integrate"
}

provider "aws" {
  region  = "ap-southeast-1"
  profile = "sc-course1-prod"
}