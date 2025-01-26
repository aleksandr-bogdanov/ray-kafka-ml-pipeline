output "global_name" {
  value = local.global_name
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  value = local.aws.region
}

## VPC
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_azs" {
  value = local.vpc.azs
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "vpc_public_subnets_cidrs" {
  value = local.vpc.public_subnets_cidrs
}

output "vpc_private_subnets_cidrs" {
  value = local.vpc.private_subnets_cidrs
}

output "vpc_public_subnets_ids" {
  value = module.vpc.public_subnets
}

output "vpc_private_subnets_ids" {
  value = module.vpc.private_subnets
}

output "vpc_private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "vpc_sg_base_id" {
  description = "Base SG ID"
  value       = aws_security_group.base.id
}

output "vpc_sg_allow_all_in_id" {
  description = "Allow all in SG ID"
  value       = aws_security_group.allow_all_in.id
}

output "vpc_sg_allow_all_out_id" {
  description = "Allow all out SG ID"
  value       = aws_security_group.allow_all_out.id
}

output "vpc_sg_allow_ssh_in_id" {
  description = "Allow SSH in SG ID"
  value       = aws_security_group.allow_ssh_in.id
}
output "sg_msk_id" {
  description = "MSK Security Group ID"
  value       = aws_security_group.msk.id
}

output "sg_eks_cluster_id" {
  description = "EKS Cluster Security Group ID"
  value       = aws_security_group.eks_cluster.id
}

output "sg_eks_nodes_id" {
  description = "EKS Nodes Security Group ID"
  value       = aws_security_group.eks_nodes.id
}

output "s3_bucket_name" {
  description = "S3 bucket name for storing images"
  value       = aws_s3_bucket.images.bucket
}

output "sqs_queue_url" {
  value = aws_sqs_queue.image_processing.url
}

output "sqs_queue_arn" {
  value = aws_sqs_queue.image_processing.arn
}