terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.21"
    }
  }

  required_version = ">= 1.10.0"

  # Bootstrapping: Create the bucket using the ./bootstrap directory
  # Must match aws_s3_bucket.bucket in bootstrap/backend.tf
  backend "s3" {
    bucket       = "k8tre-tfstate-0123456789abcdef"
    key          = "tfstate/dev/k8tre-dev"
    region       = "eu-west-2"
    use_lockfile = true
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      "owner" : "trevolution"
    }
  }
}

# Get IP of caller to optionally limit inbound connections
data "http" "myip" {
  url = "https://checkip.amazonaws.com/"
}

module "k8tre-eks" {
  source = "./k8tre-eks"
  # source = "git::https://github.com/k8tre/k8tre-infrastructure-aws.git?ref=main"

  region       = "eu-west-2"
  cluster_name = "k8tre-dev"
  # k8s_version       = "1.33"

  # CIDRs that have access to the K8S API, e.g. `0.0.0.0/0`
  k8s_api_cidrs = ["${chomp(data.http.myip.response_body)}/32"]
  # CIDRs that have access to services running on K8S
  service_access_cidrs = ["${chomp(data.http.myip.response_body)}/32"]

  # number_azs        = 1
  # instance_type_wg1 = "t3a.2xlarge"
  # use_bottlerocket  = false
  root_volume_size = 200
  wg1_size         = 2
  wg1_max_size     = 2

  # For available addons see
  # https://docs.aws.amazon.com/eks/latest/userguide/workloads-add-ons-available-eks.html
  # additional_eks_addons = {}

  # autoupdate_ami = false

  github_oidc_rolename = "k8tre-dev-github-oidc"
}

# Needed so that Terraform can manage the EKS auth configmap
provider "kubernetes" {
  host                   = module.k8tre-eks.cluster_endpoint
  cluster_ca_certificate = module.k8tre-eks.cluster_ca_certificate
  token                  = module.k8tre-eks.eks_token
}

output "kubeconfig_command" {
  description = "Create kubeconfig command"
  value       = "aws eks update-kubeconfig --name ${module.k8tre-eks.cluster_name}"
}

output "service_access_prefix_list" {
  description = "ID of the prefix list that can access services running on K8s"
  value       = module.k8tre-eks.service_access_cidrs_prefix_list
}
