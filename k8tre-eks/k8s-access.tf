# Roles to allow access to EKS

# Allow GitHub workflows to access AWS using OIDC (no hardcoded credentials)
# https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services

# Use in conjunction with a role, and
# https://github.com/aws-actions/configure-aws-credentials
resource "aws_iam_openid_connect_provider" "github_oidc" {
  count = var.github_oidc_rolename == null ? 0 : 1

  client_id_list = [
    "sts.amazonaws.com",
  ]
  tags = {
    "Name" = "github-oidc"
  }
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_policy" "eks_access" {
  name        = "${var.cluster_name}-eks-access"
  description = "Kubernetes EKS access to ${var.cluster_name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["eks:DescribeCluster"]
        Effect   = "Allow"
        Resource = module.eks.cluster_arn
      }
    ]
  })
}

resource "aws_iam_role" "github_oidc" {
  count = var.github_oidc_rolename == null ? 0 : 1

  name = var.github_oidc_rolename

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc[0].arn
        }
        Condition = {
          StringLike = {
            # GitHub repositories and refs allowed to use this role
            "token.actions.githubusercontent.com:sub" = var.github_oidc_role_sub
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_oidc" {
  count = var.github_oidc_rolename == null ? 0 : 1

  role       = aws_iam_role.github_oidc[0].name
  policy_arn = aws_iam_policy.eks_access.arn
}

# IAM role that can be assumed by anyone in the AWS account (assuming they have sufficient permissions)
resource "aws_iam_role" "eks_access" {
  name = "${var.cluster_name}-eks-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_access" {
  role       = aws_iam_role.eks_access.name
  policy_arn = aws_iam_policy.eks_access.arn
}
