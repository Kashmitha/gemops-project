#!/bin/bash
# vault/setup.sh
# Run AFTER Vault is deployed to EKS and unsealed.
# This script configures Kubernetes auth and injects app secrets.

set -e

NAMESPACE="vault"
SA_NAME="gemops-app"
APP_NAMESPACE="app"

echo "==> Enabling KV secrets engine..."
vault secrets enable -path=secret kv-v2

echo "==> Writing application secrets..."
vault kv put secret/gemops/app \
  secret_key="$(openssl rand -base64 32)" \
  db_password="$(openssl rand -base64 24)"

echo "==> Writing Vault policy..."
vault policy write gemops-app vault/policy.hcl

echo "==> Enabling Kubernetes auth method..."
vault auth enable kubernetes

echo "==> Configuring Kubernetes auth..."
vault write auth/kubernetes/config \
  kubernetes_host="https://${KUBERNETES_PORT_443_TCP_ADDR}:443"

echo "==> Creating Kubernetes auth role..."
vault write auth/kubernetes/role/gemops-app \
  bound_service_account_names=${SA_NAME} \
  bound_service_account_namespaces=${APP_NAMESPACE} \
  policies=gemops-app \
  ttl=1h

echo "==> Vault setup complete."
echo "    Secrets path: secret/gemops/app"
echo "    Policy: gemops-app"
echo "    K8s role: gemops-app"