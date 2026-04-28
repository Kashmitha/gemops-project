# GemOps — Production Observability Platform on AWS

Full-stack DevOps project: EKS cluster provisioned with Terraform 1.14.9,
Flask application deployed via Helm, complete observability with Prometheus,
Grafana 13, Loki 3.7.1, Alloy, and Alertmanager.
Secrets managed by Vault 2.0. CI/CD via GitHub Actions.

## Stack
- **IaC**: Terraform 1.14.9 + AWS provider
- **Orchestration**: AWS EKS 1.32
- **Observability**: Prometheus + Grafana 13 + Loki 3.7.1 + Alloy 1.7
- **Secrets**: HashiCorp Vault 2.0
- **CI/CD**: GitHub Actions
