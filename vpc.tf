
# Get available Availability Zones in Mumbai
data "aws_availability_zones" "available" {
  state = "available"
}

# Create VPC and networking resources
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = "eks-demo-vpc"
  cidr = "10.0.0.0/16"

  azs = ["ap-south-1a"]

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"         = "1"
    "kubernetes.io/cluster/eks-demo" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/eks-demo"  = "shared"
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "eks-demo"
  }
}


