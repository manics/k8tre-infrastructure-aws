
data "aws_eks_cluster" "target" {
  name = var.target_cluster_name
}
data "aws_eks_cluster_auth" "target_auth" {
  name = var.target_cluster_name
}

# https://github.com/argoproj/argo-helm/tree/argo-cd-9.0.5/charts/argo-cd
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "9.0.5"
  namespace  = "argocd"

  values = [
    templatefile("apps/argocd.yaml", {
      server       = data.aws_eks_cluster.target.endpoint
      cluster_name = var.target_cluster_name
      role_arn     = var.target_role_arn
      cluster_ca   = data.aws_eks_cluster.target.certificate_authority.0.data
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}
