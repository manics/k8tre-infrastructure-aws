
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

  provider = helm.k8tre-dev-argocd
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  provider = kubernetes.k8tre-dev-argocd
}

# Add k8tre-dev cluster to ArgoCD
# https://argo-cd.readthedocs.io/en/release-3.1/operator-manual/declarative-setup/#eks
resource "kubernetes_secret" "argocd-cluster-k8tre-dev" {
  metadata {
    name      = "argocd-cluster-${data.aws_eks_cluster.deployment.id}"
    namespace = "argocd"
    labels = merge(
      { "argocd.argoproj.io/secret-type" = "cluster" },
      var.k8tre_cluster_labels
    )
  }
  data = {
    config = jsonencode({
      awsAuthConfig = {
        clusterName = data.aws_eks_cluster.deployment.id
        roleARN     = data.terraform_remote_state.k8tre.outputs.k8tre_eks_access_role
      }
      tlsClientConfig = {
        caData = data.aws_eks_cluster.deployment.certificate_authority.0.data
      }
    })
    name   = data.aws_eks_cluster.deployment.id
    server = data.aws_eks_cluster.deployment.endpoint
  }

  provider = kubernetes.k8tre-dev-argocd
}
