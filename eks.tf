module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.24.2"

  name               = "eks-demo"
  kubernetes_version = "1.33"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  endpoint_public_access       = true
  endpoint_public_access_cidrs = ["27.61.39.155/32"]

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    general = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "eks-demo"
  }
}


