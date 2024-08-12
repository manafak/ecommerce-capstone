provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                  = "kingsley-vpc"
  cidr                  = "10.0.0.0/16"
  azs                   = ["us-east-1a", "us-east-1b"]
  private_subnets       = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets        = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway    = true
  single_nat_gateway    = true
  enable_dns_hostnames  = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "sockShop"
  cluster_version = "1.30"
  cluster_endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    node1 = {
      name            = "node-group1"
      instance_types  = ["t2.medium"]
      min_size        = 1
      max_size        = 2
      desired_size    = 2
    }
    node2 = {
      name            = "node-group2"
      instance_types  = ["t2.medium"]
      min_size        = 1
      max_size        = 2
      desired_size    = 2
    }
  }

  enable_cluster_creator_admin_permissions = true
}

# Data source to reference existing KMS Key Alias
data "aws_kms_alias" "existing" {
  name = "alias/eks/sockShop" # The alias name you're querying
}

# Create KMS Key if it does not exist
resource "aws_kms_key" "this" {
  count       = length(data.aws_kms_alias.existing.name) == 0 ? 1 : 0
  description = "KMS key for EKS cluster"
  key_usage   = "ENCRYPT_DECRYPT"
  tags = {
    Name = "eks-sockShop-key"
  }
}

# Create KMS Alias if it does not exist
resource "aws_kms_alias" "this" {
  count          = length(data.aws_kms_alias.existing.name) == 0 ? 1 : 0
  name           = "alias/eks/sockShop"
  target_key_id  = aws_kms_key.this.id

  lifecycle {
    create_before_destroy = true
  }
}

# Data source to reference existing CloudWatch Log Group
data "aws_cloudwatch_log_group" "existing" {
  name = "/aws/eks/sockShop/cluster"
}

# Create CloudWatch Logs Log Group if it does not exist
resource "aws_cloudwatch_log_group" "this" {
  count              = length(data.aws_cloudwatch_log_group.existing.name) == 0 ? 1 : 0
  name               = "/aws/eks/sockShop/cluster"
  retention_in_days  = 7

  lifecycle {
    create_before_destroy = true
  }
}







