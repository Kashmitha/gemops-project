# Data sources
data "aws_availability_zones" "available" {
    state = "available"
}

data "aws_caller_identity" "current" {}

# VPC
module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "~> 5.19"

    name = "${var.cluster_name}-vpc"
    cidr = "10.0.0.0/16"

    azs             = slice(data.aws_availability_zones.available.names, 0, 2)
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

    enable_nat_gateway   = true
    single_nat_gateway   = true
    enable_dns_hostnames = true

    # Required tags for EKS
    public_subnet_tags = {
        "kubernetes.io/role/elb" = 1
    }
    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
    }
}

# IAM role for EBS CSI Driver
# NOTE: This must be a top-level block — NOT nested inside module "eks"
module "ebs_csi_irsa_role" {
    source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
    version = "~> 5.39"

    role_name             = "gemops-ebs-csi-driver"
    attach_ebs_csi_policy = true

    oidc_providers = {
        ex = {
            provider_arn               = module.eks.oidc_provider_arn
            namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
        }
    }
}

# EKS Cluster
module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 20.36"

    cluster_name    = var.cluster_name
    cluster_version = var.cluster_version

    vpc_id                         = module.vpc.vpc_id
    subnet_ids                     = module.vpc.private_subnets
    cluster_endpoint_public_access = true

    # EKS managed node group
    eks_managed_node_groups = {
        general = {
            instance_types = var.node_instance_types
            min_size       = var.node_min_size
            max_size       = var.node_max_size
            desired_size   = var.node_desired_size

            # Spot instances for cost saving on dev workloads
            capacity_type = "ON_DEMAND"

            labels = {
                role = "general"
            }

            taints = []
        }
    }

    # Cluster addons
    cluster_addons = {
        coredns    = { most_recent = true }
        kube-proxy = { most_recent = true }
        vpc-cni    = { most_recent = true }

        aws-ebs-csi-driver = {
            most_recent              = true
            service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
        }
    }

    enable_cluster_creator_admin_permissions = true
}