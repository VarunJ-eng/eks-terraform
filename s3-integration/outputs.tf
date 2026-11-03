
output "s3_bucket_name" {
  value = aws_s3_bucket.eks_bucket.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.eks_bucket.arn
}

output "iam_role_arn" {
  value = aws_iam_role.eks_s3_role.arn
}

output "service_account_name" {
  value = kubernetes_service_account_v1.s3_access.metadata[0].name
}
