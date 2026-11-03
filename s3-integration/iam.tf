
locals {
  oidc_issuer_url = data.aws_eks_cluster.existing.identity[0].oidc[0].issuer

  oidc_provider_host = replace(
    local.oidc_issuer_url,
    "https://",
    ""
  )
}

data "tls_certificate" "eks" {
  count = var.create_oidc_provider ? 1 : 0
  url   = local.oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  count = var.create_oidc_provider ? 1 : 0

  url = local.oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks[0].certificates[0].sha1_fingerprint
  ]
}

data "aws_iam_openid_connect_provider" "existing" {
  count = var.create_oidc_provider ? 0 : 1
  url   = local.oidc_issuer_url
}

locals {
  oidc_provider_arn = (
    var.create_oidc_provider
    ? aws_iam_openid_connect_provider.eks[0].arn
    : data.aws_iam_openid_connect_provider.existing[0].arn
  )
}

data "aws_iam_policy_document" "eks_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        local.oidc_provider_arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:sub"

      values = [
        "system:serviceaccount:${var.namespace}:${var.service_account_name}"
      ]
    }
  }
}

resource "aws_iam_role" "eks_s3_role" {
  name               = "eks-s3-access-role"
  assume_role_policy = data.aws_iam_policy_document.eks_trust.json
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.eks_bucket.arn
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload"
    ]

    resources = [
      "${aws_s3_bucket.eks_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name   = "eks-s3-access-policy"
  policy = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_role_policy_attachment" "s3_attachment" {
  role       = aws_iam_role.eks_s3_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "kubernetes_service_account_v1" "s3_access" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_s3_role.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.s3_attachment
  ]
}
