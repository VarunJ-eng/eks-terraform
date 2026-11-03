
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "eks-new"
}

variable "cluster_name" {
  description = "Existing EKS cluster name"
  type        = string
  default     = "eks-demo"
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "eks-demo-s3-487043668737-ap-south-1"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "dev"
}

variable "service_account_name" {
  description = "Kubernetes service account"
  type        = string
  default     = "s3-access-sa"
}

variable "create_oidc_provider" {
  description = "Create OIDC provider if it does not exist"
  type        = bool
  default     = false
}

