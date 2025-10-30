output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = var.cluster_name
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

data "tls_certificate" "cluster_tls_certificate" {
  url = module.eks.cluster_oidc_issuer_url
}

output "cluster_tls_certificate_sha1_fingerprint" {
  description = "The SHA1 fingerprint of the public key of the cluster's certificate"
  value       = data.tls_certificate.cluster_tls_certificate.certificates[*].sha1_fingerprint
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS Kubernetes API"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "The EKS certificate authority data in base64"
  value       = module.eks.cluster_certificate_authority_data
}
output "eks_token" {
  description = "The EKS token"
  value       = data.aws_eks_cluster_auth.k8tre.token
}

output "service_access_cidrs_prefix_list" {
  description = "ID of the prefix list that can access services running on K8s"
  value       = aws_ec2_managed_prefix_list.service-access-cidrs.id
}

output "eks_access_role" {
  description = "ARN of a role that can access this EKS cluster"
  value       = aws_iam_role.eks_access.arn
}
