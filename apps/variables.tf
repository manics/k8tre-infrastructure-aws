
# Update this to point to your terraform state from ../main.tf
data "terraform_remote_state" "k8tre" {
  backend = "s3"

  config = {
    bucket = "k8tre-tfstate-0123456789abcdef"
    key    = "tfstate/dev/k8tre-dev"
    region = "eu-west-2"
  }
}

# Cluster where K8TRE wil be deployed
data "aws_eks_cluster" "k8tre" {
  name = data.terraform_remote_state.k8tre.outputs.k8tre_cluster_name
}
data "aws_eks_cluster_auth" "k8tre" {
  name = data.terraform_remote_state.k8tre.outputs.k8tre_cluster_name
}

# Cluster where ArgoCD is deployed
data "aws_eks_cluster" "argocd" {
  name = data.terraform_remote_state.k8tre.outputs.k8tre_argocd_cluster_name
}
data "aws_eks_cluster_auth" "argocd" {
  name = data.terraform_remote_state.k8tre.outputs.k8tre_argocd_cluster_name
}


# Cluster where K8TRE is deployed by ArgoCD
data "aws_eks_cluster" "deployment" {
  name = data.terraform_remote_state.k8tre.outputs.k8tre_cluster_name
}
data "aws_eks_cluster_auth" "deployment" {
  name = data.terraform_remote_state.k8tre.outputs.k8tre_cluster_name
}
