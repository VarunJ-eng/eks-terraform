terraform {
  backend "s3" {
    bucket       = "eks-terraform-state-487043668737-745830"
    key          = "eks-demo/terraform.tfstate"
    region       = "ap-south-1"
    profile      = "eks-new"
    encrypt      = true
    use_lockfile = true
  }
}
