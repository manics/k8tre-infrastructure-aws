# EKS pod identities for Kubernetes Service Accounts

# https://registry.terraform.io/modules/terraform-aws-modules/eks-pod-identity/aws/latest

module "eks_pod_identity_load_balancer" {
  source                          = "terraform-aws-modules/eks-pod-identity/aws"
  version                         = "2.0.0"
  name                            = "${var.cluster_name}-aws-lb-controller"
  attach_aws_lb_controller_policy = true
}

# Associate identity with the ServiceAccount that will be created by the
# aws-load-balancer-controller Helm chart
resource "aws_eks_pod_identity_association" "aws-lb-controller" {
  cluster_name    = var.cluster_name
  namespace       = "loadbalancer"
  service_account = "aws-load-balancer-controller"
  role_arn        = module.eks_pod_identity_load_balancer.iam_role_arn
}

module "aws_ebs_csi_pod_identity" {
  source                    = "terraform-aws-modules/eks-pod-identity/aws"
  version                   = "2.0.0"
  name                      = "aws-ebs-csi"
  attach_aws_ebs_csi_policy = true
  aws_ebs_csi_kms_arns      = ["arn:aws:kms:*:*:key/*"]
}

module "aws_efs_csi_pod_identity" {
  source                    = "terraform-aws-modules/eks-pod-identity/aws"
  version                   = "2.0.0"
  name                      = "aws-efs-csi"
  attach_aws_efs_csi_policy = true
}

module "cluster_autoscaler_pod_identity" {
  source                           = "terraform-aws-modules/eks-pod-identity/aws"
  version                          = "2.0.0"
  name                             = "cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [var.cluster_name]
}

# Associate identity with the ServiceAccount that will be created by the
# cluster-autoscaler Helm chart
resource "aws_eks_pod_identity_association" "cluster-autoscaler" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "cluster-autoscaler-sa"
  role_arn        = module.cluster_autoscaler_pod_identity.iam_role_arn
}
