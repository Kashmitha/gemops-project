output "cluster_name" {
    value = module.eks.cluster_name
}

output "cluster_endpoint" {
    value = module.eks.cluster_endpoint
    sensitive = true
}

output "cluster_certificate_authority_data" {
    value = module.eks.cluster_certificate_authority_data
    sensitive = true
}

output "configure_kubectl" {
    description = "Run this command to configure kubectl"
    value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "account_id" {
    value = data.aws_caller_identity.current.account_id
}