# Monitoring (Prometheus + Grafana)

Prometheus scrapes the `mini-devops-lab` pods every 15 seconds.
Grafana shows the data on a dashboard that is loaded from files
(dashboard as code), so nothing is lost when the Grafana pod restarts.

## Files

| File | What it does |
|------|--------------|
| `namespace.yaml` | Creates the `monitoring` namespace |
| `prometheus-rbac.yaml` | ServiceAccount + read-only access to pods in `mini-lab` |
| `prometheus-config.yaml` | Scrape config: Prometheus itself + the app pods |
| `prometheus.yaml` | Prometheus Deployment + Service (port 9090) |
| `grafana-datasources.yaml` | Prometheus datasource for Grafana |
| `grafana-dashboard-provider.yaml` | Tells Grafana where dashboard files live |
| `grafana-dashboard.yaml` | The dashboard JSON (4 panels) |
| `grafana.yaml` | Grafana Deployment + Service (port 3000) |

## Requirements

- The app is already running in the `mini-lab` namespace.

## Setup

Order matters. The namespace must exist first, and Grafana needs
its Secret and ConfigMaps before it starts.
`kubectl apply -f k8s/monitoring/` is not used on purpose:
it applies files in alphabetical order, so it fails on a fresh cluster.

### 1. Namespace and Prometheus

```bash
kubectl apply -f k8s/monitoring/namespace.yaml
kubectl apply -f k8s/monitoring/prometheus-rbac.yaml
kubectl apply -f k8s/monitoring/prometheus-config.yaml
kubectl apply -f k8s/monitoring/prometheus.yaml
```

### 2. Grafana admin Secret (never stored in git)

The password is typed at a hidden prompt, so it does not end up
in the shell history or in any file.

```bash
read -r -p "Grafana admin user: " GF_USER
read -rs -p "Grafana admin password: " GF_PASS; echo
kubectl create secret generic grafana-admin -n monitoring \
  --from-literal=admin-user="$GF_USER" \
  --from-literal=admin-password="$GF_PASS"
unset GF_USER GF_PASS
```

### 3. Grafana

```bash
kubectl apply -f k8s/monitoring/grafana-datasources.yaml
kubectl apply -f k8s/monitoring/grafana-dashboard-provider.yaml
kubectl apply -f k8s/monitoring/grafana-dashboard.yaml
kubectl apply -f k8s/monitoring/grafana.yaml
```

### 4. Check

```bash
kubectl get pods -n monitoring
kubectl rollout status deployment/prometheus -n monitoring
kubectl rollout status deployment/grafana -n monitoring
```

## Access

Run each in its own terminal and keep it open:

```bash
kubectl port-forward -n monitoring svc/prometheus 9090:9090
kubectl port-forward -n monitoring svc/grafana 3000:3000
```

- Prometheus: http://127.0.0.1:9090 (check Status > Targets, all UP)
- Grafana: http://127.0.0.1:3000 (dashboard in folder `mini-lab`)

Use `127.0.0.1`, not `localhost`: `localhost` may resolve to IPv6 (`::1`).
If the Grafana pod is replaced, the port-forward stops; start it again.

## Dashboard

| Panel | Query |
|-------|-------|
| Requests per second (per pod) | `sum by (pod) (rate(app_requests_total[1m]))` |
| Total requests | `sum(app_requests_total)` |
| Pods up (red below 2) | `sum(up{job="mini-devops-lab"})` |
| Memory per pod | `sum by (pod) (process_resident_memory_bytes{job="mini-devops-lab"})` |

To change the dashboard:

1. Edit `grafana-dashboard.yaml` (editing in the UI is disabled on purpose).
2. `kubectl apply -f k8s/monitoring/grafana-dashboard.yaml`
3. Wait about 1-2 minutes (no pod restart needed).
4. Reload the browser page. The Grafana refresh button only re-runs queries.

Note: `Total requests` drops when an app pod restarts,
because each pod keeps its own counter in memory.

## Generate test traffic

Runs from inside the cluster, so the Service balances requests across pods:

```bash
kubectl run load-test --rm -it --restart=Never -n mini-lab \
  --image=curlimages/curl:8.11.1 -- sh -c \
  'for i in $(seq 1 300); do curl -s -o /dev/null http://mini-devops-lab/; sleep 0.2; done; echo done'
```

## Limits (kept basic on purpose)

- Storage is `emptyDir`: Prometheus keeps 1 day of data and loses it
  when its pod is deleted. Grafana settings come back from the files above.
- One replica each, no alerting yet.
