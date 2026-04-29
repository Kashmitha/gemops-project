variable "aws_region" {
    description = "AWS region for all resources"
    type = string
    default = "ap-southeast-1"
}

variable "environment" {
    description = "Environment name"
    type = string
    default = "dev"
}

variable "cluster_name" {
    description = "EKS cluster name"
    type = string
    default = "gemops-cluster"
}

variable "cluster_version" {
    description = "Kubernetes version"
    type = string
    default = "1.32"
}

variable "node_instance_type" {
    description = "EC2 instance type for EKS nodes"
    type = string
    default = "t3.medium"
}

variable "node_desired_size" {
    type = number
    default = 2
}

variable "node_min_size" {
    type = number
    default = 1
}

variable "node_max_size" {
    type = number
    default = 4
}