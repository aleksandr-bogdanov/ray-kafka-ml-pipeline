resource "aws_security_group" "base" {
  name        = "base"
  description = "Allow all traffic from itself"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
  }
  tags = {
    Name      = "base"
    Terraform = "true"
  }
}

resource "aws_security_group" "allow_all_in" {
  name        = "allow-all-in"
  description = "Allow all incoming traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name      = "allow_all_in"
    Terraform = "true"
  }
}

resource "aws_security_group" "allow_all_out" {
  name        = "allow-all-out"
  description = "Allow all outgoing traffic"
  vpc_id      = module.vpc.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name      = "allow_all_out"
    Terraform = "true"
  }
}

resource "aws_security_group" "allow_ssh_in" {
  name        = "allow-ssh-in"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "allow_ssh_in"
    Terraform = "true"
  }
}

# msk.tf
resource "aws_security_group" "msk" {
  name        = "${local.global_name}-msk"
  description = "Security group for MSK cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    security_groups = [aws_security_group.base.id]
  }

  ingress {
    from_port       = 9094
    to_port         = 9094
    protocol        = "tcp"
    security_groups = [aws_security_group.base.id]
  }

  tags = {
    Name = "${local.global_name}-msk"
  }
}

# eks.tf
resource "aws_security_group" "eks_cluster" {
  name        = "${local.global_name}-eks-cluster"
  description = "Security group for EKS cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.base.id]
  }

  tags = {
    Name = "${local.global_name}-eks-cluster"
  }
}

resource "aws_security_group" "eks_nodes" {
  name        = "${local.global_name}-eks-nodes"
  description = "Security group for EKS worker nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  tags = {
    Name = "${local.global_name}-eks-nodes"
  }
}