
# # https://github.com/argoproj/argo-helm/tree/argo-cd-9.0.5/charts/argo-cd
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "9.0.5"
  namespace  = "argocd"

  values = [
    templatefile("./argocd.yaml", {
      deployment_server       = data.aws_eks_cluster.deployment.endpoint
      deployment_cluster_name = data.aws_eks_cluster.deployment.id
      deployment_cluster_ca   = data.aws_eks_cluster.deployment.certificate_authority.0.data
      deployment_role_arn     = data.terraform_remote_state.k8tre.outputs.k8tre_eks_access_role
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}
