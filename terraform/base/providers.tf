terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-abogdanov"
    key     = "states/base"
    region  = "eu-central-1"
    encrypt = "true"
  }

  required_version = "~> 1.3"
}

provider "aws" {
  region = local.aws.region
}

data "aws_caller_identity" "current" {}