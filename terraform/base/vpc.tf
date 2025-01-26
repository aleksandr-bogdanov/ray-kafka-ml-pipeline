module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = local.vpc.name
  cidr = local.vpc.cidr

  azs = local.vpc.azs
  private_subnets = local.vpc.private_subnets_cidrs
  public_subnets  = local.vpc.public_subnets_cidrs

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Tags for Kubernetes integration
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.eks.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                          = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.eks.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                 = 1
  }
}