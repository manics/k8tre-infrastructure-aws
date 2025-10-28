variable "cluster_name" {
  type        = string
  description = "EKS cluster name where ArgoCD should be deployed"
}

variable "target_cluster_name" {
  type        = string
  description = "EKS cluster name that ArgoCD should target"
}

variable "target_role_arn" {
  type        = string
  description = "ARN of a role that ArgoCD can assume"
}
