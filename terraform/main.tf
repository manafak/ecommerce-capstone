module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "sockShop"
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    node1 = {
      name           = "node-group1"
      instance_types = ["t2.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 2
    }

    node2 = {
      name           = "node-group2"
      instance_types = ["t2.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 2
    }
  }

  enable_cluster_creator_admin_permissions = true
}
