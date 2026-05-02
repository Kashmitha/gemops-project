<div align="center">

# GemOps

### Production-Grade Observability & Secrets Platform on AWS EKS

[![CI/CD](https://github.com/Kashmitha/gemops-project/actions/workflows/deploy.yml/badge.svg)](https://github.com/Kashmitha/gemops-project/actions)
[![Terraform](https://img.shields.io/badge/Terraform-1.14.9-7B42BC?logo=terraform)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.32-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![Helm](https://img.shields.io/badge/Helm-3.17-0F1689?logo=helm)](https://helm.sh/)
[![Vault](https://img.shields.io/badge/Vault-2.0-FFEC6E?logo=vault&logoColor=black)](https://www.vaultproject.io/)
[![Grafana](https://img.shields.io/badge/Grafana-13.0-F46800?logo=grafana)](https://grafana.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**A complete cloud-native DevOps platform demonstrating infrastructure as code, automated CI/CD, full-stack observability, and production secrets management on AWS.**

[Architecture](#architecture) · [Tech Stack](#tech-stack) · [Quick Start](#quick-start) · [CI/CD Pipeline](#cicd-pipeline) · [Observability](#observability) · [Secrets Management](#secrets-management)

</div>

---

## Overview

GemOps is a production-grade DevOps platform built to demonstrate the complete lifecycle of a cloud-native application on AWS. It addresses three capabilities that are consistently missing from student and junior portfolios — **logging**, **alerting**, and **secrets management** — alongside infrastructure as code, automated deployment, and Kubernetes orchestration.

A Python Flask API serves as the application layer, instrumented with custom Prometheus metrics and structured JSON logging. The entire AWS infrastructure is provisioned with Terraform, deployed to EKS with Helm, monitored with Prometheus and Grafana, logged with Loki and Alloy, and alerted via Alertmanager to Slack — all driven by a GitHub Actions CI/CD pipeline with security scanning, zero-downtime deployments, and automatic rollback.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Developer Workstation                             │
│                    Ubuntu 24.04 (VirtualBox)                        │
└─────────────────────┬───────────────────────────────────────────────┘
                      │ git push
                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       GitHub Actions Pipeline                        │
│                                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │  Test    │  │  Build   │  │Terraform │  │  Deploy to EKS   │   │
│  │  pytest  │→ │  Docker  │  │  Plan +  │→ │  Helm upgrade    │   │
│  │  hadolint│  │  Trivy   │  │  Apply   │  │  Smoke test      │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘   │
└─────────────────────┬───────────────────────────────────────────────┘
                      │ terraform apply + helm upgrade
                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    AWS (ap-southeast-1)                              │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  VPC  10.0.0.0/16                                           │   │
│  │                                                             │   │
│  │  Public Subnets          Private Subnets                    │   │
│  │  10.0.101.0/24           10.0.1.0/24  ┌─────────────────┐  │   │
│  │  10.0.102.0/24           10.0.2.0/24  │  EKS 1.32       │  │   │
│  │       │                               │                  │  │   │
│  │  NAT Gateway             ┌────────────┤  namespace: app  │  │   │
│  │  (single)                │            │  Flask API x2-6  │  │   │
│  │                          │            │  HPA enabled     │  │   │
│  │                          │            ├──────────────────┤  │   │
│  │                          │            │ namespace:       │  │   │
│  │                          │            │ monitoring       │  │   │
│  │                          │            │ Prometheus       │  │   │
│  │                          │            │ Grafana 13       │  │   │
│  │                          │            │ Loki 3.7.1       │  │   │
│  │                          │            │ Alloy 1.7        │  │   │
│  │                          │            │ Alertmanager     │  │   │
│  │                          │            ├──────────────────┤  │   │
│  │                          │            │ namespace: vault │  │   │
│  │  S3 (tfstate) ───────────┘            │ Vault 2.0       │  │   │
│  │  DynamoDB (lock)                      └─────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                      │ alerts
                      ▼
              Slack #gemops-alerts
```

---

## Tech Stack

| Component | Technology | Version |
|---|---|---|
| Infrastructure as Code | Terraform | 1.14.9 |
| Container Orchestration | AWS EKS | 1.32 |
| Package Management | Helm | 3.17.0 |
| Secrets Management | HashiCorp Vault | 2.0 |
| Metrics | Prometheus | 2.52 |
| Dashboards | Grafana | 13.0.1 |
| Log Aggregation | Grafana Loki | 3.7.1 |
| Log Collection | Grafana Alloy | 1.7 |
| Alert Routing | Alertmanager | 0.32.0 |
| CI/CD | GitHub Actions | Latest |
| Application | Python Flask | 3.1.0 |
| Container Runtime | Docker | 27.x |
| Security Scanning | Trivy | v0.36.0 |
| OS | Ubuntu | 24.04 LTS |

---

## Repository Structure

```
gemops-project/
├── .github/
│   └── workflows/
│       └── deploy.yml              # Full CI/CD pipeline
├── app/
│   ├── Dockerfile                  # Multi-stage, non-root, bookworm base
│   ├── main.py                     # Flask API with Prometheus metrics
│   ├── requirements.txt
│   └── tests/
│       └── test_main.py            # pytest test suite (6 tests)
├── terraform/
│   ├── versions.tf                 # Providers, S3 backend config
│   ├── variables.tf                # Region, cluster, node configuration
│   ├── main.tf                     # VPC + EKS modules
│   └── outputs.tf                  # Cluster endpoint, kubectl command
├── helm/
│   ├── flask-app/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   │       ├── deployment.yaml     # Rolling update, Vault annotations
│   │       ├── service.yaml        # ClusterIP :5000
│   │       ├── hpa.yaml            # Scale 2-6 at 70% CPU
│   │       └── servicemonitor.yaml # Prometheus scrape config
│   └── observability/
│       ├── kube-prometheus-stack-values.yaml
│       ├── loki-values.yaml
│       └── alloy-values.yaml
├── vault/
│   ├── policy.hcl                  # Least-privilege read policy
│   └── setup.sh                    # Vault init automation
├── docs/
│   └── runbook.md                  # Incident response procedures
└── .gitignore                      # Excludes secrets, tfstate, .env
```

---

## Quick Start

### Prerequisites

- Ubuntu 24.04 LTS (or VirtualBox VM)
- AWS account with programmatic access
- DockerHub account
- Slack workspace with incoming webhook

### Step 1 — Install Tools

```bash
# Terraform 1.14.9
wget -O- https://apt.releases.hashicorp.com/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform vault

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -sL \
  https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Docker
sudo apt install -y docker.io && sudo usermod -aG docker $USER
```

### Step 2 — Configure AWS

```bash
aws configure
# Region: ap-southeast-1

aws sts get-caller-identity   # Verify credentials
```

### Step 3 — Bootstrap Terraform Remote State

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws s3 mb s3://gemops-tfstate-${ACCOUNT_ID} --region ap-southeast-1
aws s3api put-bucket-versioning \
  --bucket gemops-tfstate-${ACCOUNT_ID} \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name gemops-tfstate-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-southeast-1
```

Update `terraform/versions.tf` with your account ID in the S3 bucket name.

### Step 4 — Provision Infrastructure

```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
cd ..

# Configure kubectl
aws eks update-kubeconfig --region ap-southeast-1 --name gemops-cluster
kubectl get nodes   # 3 nodes Ready
```

### Step 5 — Deploy Everything

```bash
# Create namespaces
kubectl create namespace app
kubectl create namespace monitoring
kubectl create namespace vault

# Add Helm repos
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Deploy Vault
helm install vault hashicorp/vault --namespace vault \
  --set "server.dev.enabled=true"

# Deploy observability stack
helm install loki grafana/loki \
  --namespace monitoring --version 6.7.1 \
  -f helm/observability/loki-values.yaml

helm install alloy grafana/alloy \
  --namespace monitoring \
  -f helm/observability/alloy-values.yaml

helm install kube-prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f helm/observability/kube-prometheus-stack-values.yaml

# Build and push application image
docker build -t YOUR_DOCKERHUB_USERNAME/gemops-flask:1.0.0 ./app
docker push YOUR_DOCKERHUB_USERNAME/gemops-flask:1.0.0

# Create app secrets
kubectl create secret generic gemops-app-secrets -n app \
  --from-literal=secret_key="$(openssl rand -base64 32)" \
  --from-literal=db_password="$(openssl rand -base64 24)"

# Deploy Flask application
helm install gemops-app ./helm/flask-app \
  --namespace app \
  --set image.repository=YOUR_DOCKERHUB_USERNAME/gemops-flask \
  --set image.tag=1.0.0

kubectl set env deployment/gemops-app-flask -n app \
  --from=secret/gemops-app-secrets
```

### Step 6 — Verify

```bash
kubectl get pods -A | grep -v Completed
helm list -A
```

---

## CI/CD Pipeline

The GitHub Actions pipeline runs automatically on every push to `main`.

```
push to main
     │
     ├──► Job 1: Test
     │         pytest (6 tests)
     │         hadolint Dockerfile lint
     │
     ├──► Job 2: Build & Push Image
     │         Docker multi-stage build
     │         Push to DockerHub (latest + SHA tag)
     │         Trivy security scan (CRITICAL only)
     │
     ├──► Job 3a: Terraform Plan
     │         terraform fmt -check
     │         terraform init + plan
     │         Upload plan artifact
     │
     ├──► Job 3b: Terraform Apply ──► [Manual Approval Required]
     │         Download plan artifact
     │         terraform apply
     │
     └──► Job 4: Deploy to EKS ──────► [Manual Approval Required]
               helm upgrade --atomic (auto-rollback on failure)
               Smoke test (in-cluster curl pod)
               Slack notification (success or failure)
```

### Required GitHub Secrets

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS programmatic access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret access key |
| `DOCKERHUB_USERNAME` | DockerHub account username |
| `DOCKERHUB_TOKEN` | DockerHub access token (Read & Write) |
| `SLACK_WEBHOOK_URL` | Slack incoming webhook URL |

---

## Observability

### Metrics — Prometheus + Grafana

The Flask application exposes three custom metrics at `/metrics`:

| Metric | Type | Description |
|---|---|---|
| `gemops_requests_total` | Counter | Total requests by method, endpoint, status |
| `gemops_request_duration_seconds` | Histogram | Request latency with buckets |
| `gemops_errors_total` | Counter | Errors by endpoint and type |

**Useful Grafana queries:**

```promql
# Request rate
rate(gemops_requests_total[5m])

# P95 latency
histogram_quantile(0.95, rate(gemops_request_duration_seconds_bucket[5m]))

# Error rate
rate(gemops_errors_total[5m])

# Pod count
count(kube_pod_status_ready{namespace="app", condition="true"})
```

### Logs — Loki + Grafana Alloy

Alloy runs as a DaemonSet collecting structured JSON logs from all pods. Query in Grafana Explore:

```logql
# All app logs
{namespace="app"}

# Error logs only
{namespace="app"} |= "ERROR"

# Error frequency over time
count_over_time({namespace="app"} |= "ERROR" [5m])
```

### Alerting — Alertmanager → Slack

Four custom alert rules route to `#gemops-alerts`:

| Alert | Condition | Severity |
|---|---|---|
| `GemOpsHighErrorRate` | Error rate > 0.1/sec for 2 min | Critical |
| `GemOpsHighLatency` | P95 latency > 500ms for 5 min | Warning |
| `GemOpsPodNotReady` | Any pod not ready for 1 min | Critical |
| `GemOpsHighCPU` | CPU > 80% for 5 min | Warning |

### Access Services Locally

```bash
# Kill existing port-forwards and start fresh
kill $(lsof -t -i:8080) $(lsof -t -i:9090) $(lsof -t -i:9093) $(lsof -t -i:3000) 2>/dev/null
sleep 2

kubectl port-forward svc/gemops-app-flask 8080:5000 -n app &
kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring &
kubectl port-forward svc/kube-prometheus-stack-alertmanager 9093:9093 -n monitoring &
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring &
```

| Service | URL | Credentials |
|---|---|---|
| Flask API | http://localhost:8080 | None |
| Prometheus | http://localhost:9090 | None |
| Alertmanager | http://localhost:9093 | None |
| Grafana | http://localhost:3000 | admin / GemOps123 |

---

## Secrets Management

HashiCorp Vault 2.0 manages application secrets using the KV v2 secrets engine with Kubernetes authentication.

```
Pod startup
    │
    ▼
Vault Agent Injector
    │
    ├── Authenticates using pod service account token
    ├── Vault verifies against Kubernetes auth method
    ├── Checks gemops-app policy (read-only on secret/gemops/app)
    └── Injects APP_SECRET_KEY and DB_PASSWORD into pod environment
```

**Vault setup:**
```bash
# Enable KV engine
kubectl exec -n vault vault-0 -- vault secrets enable -path=secret kv-v2

# Write secrets
kubectl exec -n vault vault-0 -- vault kv put secret/gemops/app \
  secret_key="$(openssl rand -base64 32)" \
  db_password="$(openssl rand -base64 24)"

# Verify
kubectl exec -n vault vault-0 -- vault kv get secret/gemops/app
```

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/` | Service info and version |
| GET | `/health` | Liveness probe |
| GET | `/ready` | Readiness probe |
| GET | `/metrics` | Prometheus metrics |
| GET | `/simulate-error` | Trigger error for alert testing |
| GET | `/load` | Generate CPU load for HPA testing |

---

## Cost Management

| Resource | Type | Monthly Cost |
|---|---|---|
| EKS control plane | Managed | ~$72 |
| t3.medium SPOT nodes x3 | Compute | ~$15 |
| NAT Gateway (single) | Networking | ~$32 |
| S3 + DynamoDB | Storage | ~$1 |
| **Total** | | **~$120/month** |

**Stop all costs when not in use:**

```bash
# Scale nodes to zero
aws eks update-nodegroup-config \
  --cluster-name gemops-cluster \
  --nodegroup-name general \
  --scaling-config minSize=0,maxSize=4,desiredSize=0 \
  --region ap-southeast-1

# Destroy everything
cd terraform && terraform destroy
```

---

## Incident Runbook

See [docs/runbook.md](docs/runbook.md) for:
- Alert investigation steps for each alert rule
- Rollback procedure with recovery time targets
- Cost management and scale-down procedures

**Quick rollback:**
```bash
helm rollback gemops-app -n app
kubectl rollout status deployment/gemops-app-flask -n app
```

---

## Key Engineering Decisions

| Decision | Rationale |
|---|---|
| SPOT instances | 80% cost reduction vs on-demand for dev workloads |
| Single NAT Gateway | Saves ~$32/month vs one per AZ |
| Helm `--atomic` flag | Automatic rollback on failed deployments |
| `maxUnavailable: 0` | Zero-downtime rolling updates |
| Trivy pinned to `v0.36.0` | Safe version post-March 2026 supply chain compromise |
| `bookworm` base image | Fewer OS-level CVEs than default `slim` |
| GitHub Push Protection | Prevented accidental Slack webhook commit |

---

## Author

**Kashmitha Madushan**  
Computer Science Undergraduate — Eastern University Sri Lanka, Trincomalee Campus  
Student ID: 21/COM/505

[![GitHub](https://img.shields.io/badge/GitHub-Kashmitha-181717?logo=github)](https://github.com/Kashmitha)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Kashmitha_Madushan-0A66C2?logo=linkedin)](https://www.linkedin.com/in/kashmitha-madushan-362822339/)
[![Email](https://img.shields.io/badge/Email-kashmithamadushan@gmail.com-D14836?logo=gmail)](mailto:kashmithamadushan@gmail.com)

---

<div align="center">

Built with focus, debugged with patience, shipped with pride.

</div>