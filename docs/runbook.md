# GemOps Operations Runbook

**Last Updated:** May 2026  
**Author:** Kashmitha Madushan  
**Cluster:** gemops-cluster (EKS 1.32, ap-southeast-1)

---

## Alert: GemOpsHighErrorRate 🔴

**Trigger:** Error rate > 0.1 errors/sec for 2 minutes  
**Severity:** Critical

### Investigation Steps

1. Check pod logs:
   ```bash
   kubectl logs -l app=flask-api -n app --tail=100
   ```
2. Query Grafana Loki for errors:
   ```
   {namespace="app", app="flask-api"} |= "ERROR"
   ```
3. Check recent deployments:
   ```bash
   kubectl rollout history deployment/gemops-app-flask -n app
   ```
4. If error started after deployment, rollback immediately:
   ```bash
   kubectl rollout undo deployment/gemops-app-flask -n app
   ```

---

## Alert: GemOpsHighLatency ⚠️

**Trigger:** P95 latency > 500ms for 5 minutes  
**Severity:** Warning

### Investigation Steps

1. Check HPA status — are pods scaling?
   ```bash
   kubectl get hpa -n app
   kubectl describe hpa gemops-app-flask-hpa -n app
   ```
2. Check node resource pressure:
   ```bash
   kubectl top nodes
   kubectl top pods -n app
   ```
3. If CPU-bound, scale manually while HPA catches up:
   ```bash
   kubectl scale deployment gemops-app-flask --replicas=5 -n app
   ```

---

## Alert: GemOpsPodNotReady 🔴

**Trigger:** Any Flask pod not ready for 1 minute  
**Severity:** Critical

### Investigation Steps

1. Describe the pod:
   ```bash
   kubectl describe pod -l app=flask-api -n app
   ```
2. Check Vault Agent logs (secrets injection may have failed):
   ```bash
   kubectl logs -l app=flask-api -n app -c vault-agent-init
   ```
3. Check if Vault is healthy:
   ```bash
   kubectl exec -n vault vault-0 -- vault status
   ```

---

## Rollback Procedure

```bash
# View revision history
kubectl rollout history deployment/gemops-app-flask -n app

# Roll back to previous version
kubectl rollout undo deployment/gemops-app-flask -n app

# Roll back to specific revision
kubectl rollout undo deployment/gemops-app-flask -n app --to-revision=2

# Verify rollback
kubectl rollout status deployment/gemops-app-flask -n app
```

**Target recovery time:** < 2 minutes

---

## Cost Management

| Resource | Monthly Estimate | Saving Option |
|---|---|---|
| EKS cluster | ~$72 | Delete when not in use |
| t3.medium SPOT nodes (x2) | ~$15 | Use spot instances (already configured) |
| NAT Gateway | ~$32 | Single NAT (already configured) |
| S3 + DynamoDB (state) | ~$1 | Negligible |
| **Total** | **~$120/month** | |

**To stop all costs when not using:**
```bash
# Scale nodes to 0 (preserves cluster, stops EC2 costs)
aws eks update-nodegroup-config \
  --cluster-name gemops-cluster \
  --nodegroup-name general \
  --scaling-config minSize=0,maxSize=4,desiredSize=0 \
  --region ap-southeast-1

# Or destroy everything
cd terraform && terraform destroy