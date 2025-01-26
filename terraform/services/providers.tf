terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-abogdanov"
    key     = "states/services"
    region  = "eu-central-1"
    encrypt = "true"
  }
  required_version = "~> 1.3"
}

provider "aws" {
  region = data.terraform_remote_state.base.outputs.aws_region
}

# provider "kubernetes" {
#   host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
#   cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name]
#   }
# }


data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    bucket  = "terraform-abogdanov"
    key     = "states/base"
    region  = "eu-central-1"
    encrypt = "true"
  }
}

data "aws_caller_identity" "current" {}
data "aws_secretsmanager_secret_version" "current" {
  secret_id = "aws_credentials"
}