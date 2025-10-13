variable "region" {
  type        = string
  description = "AWS region"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR to create"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnet CIDRs to create"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnet CIDRs to create"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes cluster version"
  default     = "1.33"
}

variable "k8s_api_cidrs" {
  type        = list(string)
  default     = ["127.0.0.1/8"]
  description = "CIDRs that have access to the K8s API"
}

variable "service_access_cidrs" {
  type        = list(string)
  default     = ["127.0.0.1/8"]
  description = "CIDRs that have access to services running on K8s"
}

variable "number_azs" {
  type = number
  # Use just one so we don't have to deal with node/volume affinity-
  # can't use EBS volumes across AZs
  default     = 1
  description = "Number of AZs to use"
}

variable "instance_type_wg1" {
  type        = string
  default     = "t3a.2xlarge"
  description = "Worker-group-1 EC2 instance type"
}

variable "use_bottlerocket" {
  type        = bool
  default     = false
  description = "Use Bottlerocket for worker nodes"
}

variable "root_volume_size" {
  type        = number
  default     = 100
  description = "Root volume size in GB"
}

variable "wg1_size" {
  type        = number
  default     = 2
  description = <<-EOT
    Worker-group-1 initial desired number of nodes.
    Note this has no effect after the cluster is provisioned:
    - https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2030
    - https://github.com/bryantbiggs/eks-desired-size-hack
    Manually change the node group size in the AWS console instead.
    EOT
}

variable "wg1_max_size" {
  type        = number
  default     = 2
  description = "Worker-group-1 maximum number of nodes"
}

variable "autoupdate_ami" {
  type        = bool
  default     = false
  description = "Whether to autoupdate the AMI version when Terraform is run"
}

variable "additional_eks_addons" {
  type        = map(any)
  default     = {}
  description = "Map of additional EKS addons"
}

variable "github_oidc_rolename" {
  type        = string
  description = "The name of the IAM role that will be created for the GitHub OIDC provider, set to null to disable"
  default     = null
}

variable "github_oidc_role_sub" {
  type        = list(string)
  description = "List of githubusercontent.com:sub repositories and refs allowed to use the OIDC role"
  # default     = ["repo:k8tre/k8tre:ref:refs/heads/main"]
  default = []
}
