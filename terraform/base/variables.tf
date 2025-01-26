locals {
  global_name = "abogdanov-ray-kafka-ml-pipeline"

  aws = {
    region = "eu-central-1"
  }

  eks = {
    cluster_name = local.global_name
  }

  vpc = {
    # CIDRs
    # https://www.calculator.net/ip-subnet-calculator.html?cclass=a&csubnet=18&cip=10.0.0.0&ctype=ipv4&printit=0&x=75&y=21
    name                  = local.global_name
    cidr                  = "10.0.0.0/16"
    public_subnets_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
    azs                   = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  }
}