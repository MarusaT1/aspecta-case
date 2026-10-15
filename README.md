# Cloud-Native Production Environment in Kubernetes (Frontend + Backend)

This project represents a complete implementation of the assignment for the design and deployment of a scalable, secure, and monitored staging environment in Kubernetes, utilizing modern GitOps and CI/CD methodologies.

## 🏗️ Architecture and Technologies Used
* **Local Cluster:** Minikube (with the `ingress` addon enabled)
* **Packaging and Templating:** Helm (Chart version v3)
* **GitOps Continuous Delivery:** ArgoCD (declarative synchronization, Self-Healing, Pruning)
* **CI/CD Pipeline:** GitHub Actions (automated Docker Build & Push, GitOps State Update)
* **Traffic Routing (Ingress):** Nginx Ingress Controller (mapping the `staging.webapp.local` domain)
* **Monitoring:** Prometheus Operator (`PrometheusRule` for application alerts)

---

## 🔒 Security (Security Hardening)
1. **Network Isolation (NetworkPolicy):** A strict Ingress NetworkPolicy is implemented for the backend within the `staging` namespace. The backend accepts network traffic **exclusively** from pods carrying the label `app.kubernetes.io/name: frontend`. Any other traffic (including traffic from other namespaces) is dropped at the network layer.
2. **Configuration Separation:** Sensitive data (database passwords) is strictly separated from the application code and injected at runtime via Kubernetes `Secret` (Opaque) objects. Non-sensitive configuration state is managed via a `ConfigMap`.
3. **RBAC:** The templates include a dedicated `ServiceAccount` and a `RoleBinding`, restricting the permissions of external management tools to only the bare minimum operations required over the respective Deployments.

---

## 🔄 CI/CD & GitOps Workflow
The entire application deployment lifecycle is fully automated, removing the need for manual administrator intervention:

1. **The developer** makes a change in the source code (`frontend/` or `backend/`) and pushes the code to the `main` branch.
2. **GitHub Actions Workflow** (`.github/workflows/cicd.yml`):
   * Authenticates and logs into the Docker Registry (Docker Hub) using secure repository Secrets.
   * Builds staging Docker images tagged with a unique `github.sha`.
   * Pushes the images to the registry.
   * **GitOps Step:** A `sed` command automatically locates and overwrites the `tag:` value inside the configuration file `charts/webapp/values.yaml` with the new commit SHA and pushes this change back to GitHub.
3. **ArgoCD Application Controller:**
   * Detects the change in the Git repository (change in the Desired State).
   * Evaluates the cluster state as `OutOfSync` and immediately triggers automated remediation.
   * Executes a zero-downtime rolling update (thanks to the configured replica count) and deploys the new container versions.

---

## 🚀 Installation and Local Execution (Verification)

### 1. Preparing Minikube
```bash
minikube start
minikube addons enable ingress
```

### 2. Local Deployment of Helm Template (Alternative Manual Apply)
```bash
kubectl create namespace staging
helm template staging charts/webapp --namespace staging | kubectl apply -n staging -f -
```

### 3. Deploying the Local Prometheus Monitoring Server
```bash
kubectl apply -f prometheus-server.yaml
```

### 4. Setting Up Local Routing
Find the cluster IP address using `minikube ip` and add the following entry to your `/etc/hosts` file:
```text
<MINIKUBE_IP> staging.webapp.local
```

The application is then accessible at: **http://staging.webapp.local**
