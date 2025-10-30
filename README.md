# K8TRE AWS base infrastructure

[![Lint](https://github.com/manics/k8tre-infrastructure-aws/actions/workflows/lint.yml/badge.svg)](https://github.com/manics/k8tre-infrastructure-aws/actions/workflows/lint.yml)

Deploy AWS infrastructure using Terraform to support [K8TRE](https://github.com/k8tre/k8tre).

## First time

You must first create a S3 bucket to store the [Terraform state file](https://developer.hashicorp.com/terraform/language/state).
Activate your AWS credentials in your shell environment, edit the `resource.aws_s3_bucket.bucket` `bucket` name in [`bootstrap/backend.tf`](bootstrap/backend.tf), then:

```sh
cd backend
terraform init
terraform apply
cd ..
```

## Deploy Amazon Elastic Kubernetes Service (EKS)

By default this 3will deploy two EKS clusters:
- `k8tre-dev-argocd` is where ArgoCD will run
- `k8tre-dev` is where K8TRE will be deployed

IAM roles and pod identities are setup to allow ArgoCD running in the `k8tre-dev-argocd` cluster to have admin access to the `k8tre-dev` cluster.

### Configuration

Edit [`main.tf`](main.tf).
You must modify `terraform.backend.s3` `bucket` to match the one in `bootstrap/backend.tf`, and you may want to modify the configuration of `module.k8tre-eks`.

If you want to deploy ArgoCD in the same cluster as K8TRE delete
- `module.k8tre-argocd-eks`
- `output.kubeconfig_command_k8tre-argocd-dev`

### Run Terraform

Activate your AWS credentials in your shell environment, then:

```sh
terraform init
terraform apply
```
If there's a timeout run
```sh
terraform apply
```
again.

### Install ArgoCD

Edit [`apps/variables.tf`](apps/variables.tf):
- Modify `terraform.backend.s3` `bucket` to match the one in `bootstrap/backend.tf`.
- Change the `data.terraform_remote_state.k8tre` section to match the `backend.s3` section in `main.tf`.
  This allows the ArgoCD terraform to automatically lookup up the EKS details without needing to specify everything manually.

## `k8tre-dev` cluster setup

`terraform apply` should display the command to create `kubeconfig` file for the `k8tre-dev` cluster.
Create and activate it.

### Deploy a default storage class using EBS

```sh
kubectl apply -f manifests/default-storageclass.yaml
```

### Setup Cillium
https://docs.cilium.io/en/latest/installation/cni-chaining-aws-cni/

```sh
helm repo add cilium https://helm.cilium.io/
helm upgrade --install cilium cilium/cilium --version 1.18.2 \
  --namespace kube-system \
  --set cni.chainingMode=aws-cni \
  --set cni.exclusive=false \
  --set enableIPv4Masquerade=false \
  --set routingMode=native \
  --wait
```

Now follow the remaining steps in
https://github.com/k8tre/k8tre/blob/main/docs/development/k3s-dev.md#setup-argocd
to setup ArgoCD.

## Things to note

EKS is deployed in a private subnet, with NAT gateway to a public subnet
A [GitHub OIDC role](https://docs.github.com/en/actions/concepts/security/openid-connect) can optionally be created.

The cluster has a single EKS node group in a single subnet (single availability zone) to reduce costs, and to avoid multi-AZ storage.
If you require multi-AZ high-availability you will need to modify this.

A prefix list `${var.cluster_name}-service-access-cidrs` is provided for convenience
This is not used in any Terraform resource, but can be referenced in Application load balancers deployed in EKS

## Optional wildcard certificate (not currently automated)

To simplify certificate management in K8TRE you can optionally create a wildcard public certificate using [Amazon Certificate Manager](https://docs.aws.amazon.com/acm/latest/userguide/acm-public-certificates.html).
This certificate can then be used in AWS load balancers provisioned by K8TRE without further configuration.




## Developer notes

To debug Argocd inter-cluster auth:

```sh
kubectl -nargocd exec -it deploy/argocd-server -- bash

argocd-k8s-auth aws --cluster-name k8tre-dev --role-arn arn:aws:iam::${ACCOUNT_ID}:role/k8tre-dev-eks-access
```
