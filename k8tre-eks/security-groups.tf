# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v21.3.2/docs/network_connectivity.md

resource "aws_security_group" "worker_group_all" {
  name_prefix = "worker_group_all_ports"
  vpc_id      = module.vpc.vpc_id
  description = "Allow all ports for worker group"

  ingress {
    description = "Allow all inbound traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    self        = true
  }
  egress {
    description = "Allow all outbound traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    # self      = true
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id
  description = "Worker nodes internal access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

# This is not used in any Terraform resource, but can be referenced in
# Application load balancers deployed in EKS
resource "aws_ec2_managed_prefix_list" "service-access-cidrs" {
  name           = "${var.cluster_name}-service-access-cidrs"
  address_family = "IPv4"
  max_entries    = 20

  dynamic "entry" {
    for_each = var.service_access_cidrs
    content {
      cidr = entry.value
      # description =
    }
  }
}
