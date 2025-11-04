terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }

  required_version = ">= 1.10.0"

  # Must match aws_s3_bucket.bucket in ../bootstrap/backend.tf
  backend "s3" {
    bucket       = "k8tre-tfstate-0123456789abcdef"
    key          = "tfstate/dev/k8tre-dev-apps"
    region       = "eu-west-2"
    use_lockfile = true
  }
}


provider "kubernetes" {
  alias                  = "k8tre-dev"
  host                   = data.aws_eks_cluster.k8tre.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.k8tre.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.k8tre.token
}

provider "kubernetes" {
  alias                  = "k8tre-dev-argocd"
  host                   = data.aws_eks_cluster.argocd.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.argocd.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.argocd.token
}

provider "helm" {
  alias = "k8tre-dev-argocd"
  kubernetes = {
    host                   = data.aws_eks_cluster.argocd.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.argocd.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.argocd.token
  }
}
