# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create VPC
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = var.vpc_cidr
  vpc_name            = var.vpc_name
  environment         = var.environment
  availability_zones  = var.availability_zones
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Create EKS Cluster
module "eks" {
  source = "./modules/eks"

  cluster_name    = "${var.vpc_name}-cluster"
  environment     = var.environment
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids

  kubernetes_version = var.kubernetes_version
  instance_types    = var.instance_types

  node_group_desired_size     = var.node_group_desired_size
  node_group_max_size        = var.node_group_max_size
  node_group_min_size        = var.node_group_min_size
  max_unavailable_percentage = var.max_unavailable_percentage

  depends_on = [module.vpc]
}
