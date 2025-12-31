#!/bin/bash


# AKS Gateway API Lab - Complete Guide (http-echo version)

## Overview
This lab demonstrates Azure Kubernetes Service (AKS) with Gateway API addon using Istio, featuring 4 namespaces with 3 applications each. We use `hashicorp/http-echo` instead of nginx to avoid path routing issues.

## Prerequisites
- Azure CLI installed
- kubectl installed
- An active Azure subscription
- Basic knowledge of Kubernetes

## Lab Architecture
- **4 Namespaces**: dev, staging, prod, monitoring
- **12 Applications**: 3 apps per namespace using http-echo
- **Gateway API with Istio**: For advanced traffic routing

---

## Step 1: Create AKS Cluster

```bash
# Set variables
RESOURCE_GROUP="rg-aks-gateway-lab"
CLUSTER_NAME="aks-gateway-demo"
LOCATION="northeurope"  # Gateway API supported region

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS cluster
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --location $LOCATION \
  --node-count 3 \
  --node-vm-size Standard_D2s_v3 \
  --enable-managed-identity \
  --network-plugin azure \
  --network-policy azure \
  --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing

# Verify cluster
kubectl get nodes
```

---

## Step 2: Enable Istio Service Mesh and Gateway API

```bash
# Install aks-preview extension
az extension add --name aks-preview
az extension update --name aks-preview

# Register the feature
az feature register --namespace "Microsoft.ContainerService" --name "ManagedGatewayAPIPreview"

# Check registration status (wait until "Registered")
az feature show --namespace "Microsoft.ContainerService" --name "ManagedGatewayAPIPreview"

# Register the provider
az provider register -n Microsoft.ContainerService

# Enable Istio Service Mesh addon
az aks mesh enable \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME

# Wait for Istio to be deployed (takes 5-10 minutes)
kubectl get pods -n aks-istio-system --watch

# Enable Gateway API
az aks update \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --enable-gateway-api

# Verify Gateway API CRDs are installed
kubectl api-resources | grep gateway
```

Expected output:
```
gatewayclasses
gateways
httproutes
grpcroutes
referencegrants
```

---

## Step 3: Create Namespaces

```bash
# Create all four namespaces
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace prod
kubectl create namespace monitoring

# Verify namespaces
kubectl get namespaces
```

---

## Step 4: Deploy Applications to Each Namespace

### DEV Namespace - Applications

```bash
# App 1: Frontend
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dev-frontend
  namespace: dev
spec:
  replicas: 2
  selector:
    matchLabels:
      app: dev-frontend
  template:
    metadata:
      labels:
        app: dev-frontend
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello from DEV Frontend App! 🚀 Version 1.0"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: dev-frontend
  namespace: dev
spec:
  selector:
    app: dev-frontend
  ports:
  - port: 80
    targetPort: 5678
  type: ClusterIP
EOF

# App 2: API
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dev-api
  namespace: dev
spec:
  replicas: 2
  selector:
    matchLabels:
      app: dev-api
  template:
    metadata:
      labels:
        app: dev-api
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello from DEV API App! 📡 Endpoints: /users, /products"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: dev-api
  namespace: dev
spec:
  selector:
    app: dev-api
  ports:
  - port: 80
    targetPort: 5678
  type: ClusterIP
EOF

# App 3: Backend
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dev-backend
  namespace: dev
spec:
  replicas: 2
  selector:
    matchLabels:
      app: dev-backend
  template:
    metadata:
      labels:
        app: dev-backend
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello from DEV Backend App! 💾 Database: Connected"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: dev-backend
  namespace: dev
spec:
  selector:
    app: dev-backend
  ports:
  - port: 80
    targetPort: 5678
  type: ClusterIP
EOF
```

### STAGING Namespace - Applications

```bash
# App 1: Frontend
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: staging-frontend
  namespace: staging
spec:
  replicas: 2
  selector:
    matchLabels:
      app: staging-frontend
  template:
    metadata:
      labels:
        app: staging-frontend
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello from STAGING Frontend App! ⚡ Version 1.5 - Testing Phase"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: staging-frontend
  namespace: staging
spec:
  selector:
    app: staging-frontend
  ports:
  - port: 80
    targetPort: 5678
  type: ClusterIP
EOF

# App 2: API
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: staging-api
  namespace: staging
spec:
  replicas: 2
  selector:
    matchLabels:
      app: staging-api
  template:
    metadata:
      labels:
        app: staging-api
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello from STAGING API App! 🧪 Testing new endpoints"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: staging-api
  namespace: staging
spec:
  selector:
    app: staging-api
  ports:
  - port: 80
    targetPort: 5678
  type: ClusterIP
EOF

# App 3: Backend
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: staging-backend
  namespace: staging
spec:
  replicas: 2
  selector:
    matchLabels:
      app: staging-backend
  template:
    metadata:
      labels:
        app: staging-backend
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello from STAGING Backend App! 🔧 Staging DB Connected"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: staging-backend
  namespace: staging
spec:
  selector:
    app: staging-backend
  ports:
  - port: 80
    targetPort: 5678
  type: ClusterIP
EOF
```

### PROD Namespace - Applications

```bash
# App 1: Frontend
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prod-frontend
  namespace: prod
spec:
  replicas: 3
  selector:
    matchLabels:
      app: prod-frontend
  template:
    metadata:
      labels:
        app: prod-frontend
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello from PRODUCTION Frontend App! ✨ Version 2.0 - Stable Release"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: prod-frontend
  namespace: prod
spec:
  selector:
    app: prod-frontend
  ports:
  - port: 80
    targetPort: 5678
  type: ClusterIP
EOF

# App 2: API
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prod-api
  namespace: prod
spec:
  replicas: 3
  selector:
    matchLabels:
      app: prod-api
  template:
    metadata:
      labels:
        app: prod-api
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello from PRODUCTION API App! 🌐 Live API Endpoints Serving Customers"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: prod-api
  namespace: prod
spec:
  selector:
    app: prod-api
  ports:
  - port: 80
    targetPort: 5678
  type: ClusterIP
EOF

# App 3: Backend
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prod-backend
  namespace: prod
spec:
  replicas: 3
  selector:
    matchLabels:
      app: prod-backend
  template:
    metadata:
      labels:
        app: prod-backend
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello from PRODUCTION Backend App! 🏢 Production DB - High Availability Mode"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: prod-backend
  namespace: prod
spec:
  selector:
    app: prod-backend
  ports:
  - port: 80
    targetPort: 5678
  type: ClusterIP
EOF
```

### MONITORING Namespace - Applications

```bash
# App 1: Prometheus
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello from Prometheus Monitoring App! 📊 Metrics Collection Active"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
spec:
  selector:
    app: prometheus
  ports:
  - port: 80
    targetPort: 5678
  type: ClusterIP
EOF

# App 2: Grafana
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello from Grafana Dashboard App! 📈 Visualization Platform Online"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
spec:
  selector:
    app: grafana
  ports:
  - port: 80
    targetPort: 5678
  type: ClusterIP
EOF

# App 3: AlertManager
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alertmanager
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alertmanager
  template:
    metadata:
      labels:
        app: alertmanager
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello from AlertManager App! 🚨 Alert Management System Ready"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: alertmanager
  namespace: monitoring
spec:
  selector:
    app: alertmanager
  ports:
  - port: 80
    targetPort: 5678
  type: ClusterIP
EOF
```

---

## Step 5: Verify All Deployments

```bash
# Check all deployments
kubectl get deployments --all-namespaces

# Check all services
kubectl get services --all-namespaces

# Check pods in each namespace
kubectl get pods -n dev
kubectl get pods -n staging
kubectl get pods -n prod
kubectl get pods -n monitoring
```

---

## Step 6: Create Gateway Class and Gateway

```bash
# Create GatewayClass
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: istio-gateway
spec:
  controllerName: istio.io/gateway-controller
EOF

# Create Gateway
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main-gateway
  namespace: default
spec:
  gatewayClassName: istio-gateway
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: All
EOF

# Wait for Gateway to be ready
kubectl wait --for=condition=Programmed gateway/main-gateway -n default --timeout=300s

# Get Gateway external IP
kubectl get gateway main-gateway -n default
```

---

## Step 7: Create HTTPRoutes for All Applications

### DEV Environment Routes

```bash
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: dev-routes
  namespace: dev
spec:
  parentRefs:
  - name: main-gateway
    namespace: default
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /dev/frontend
    backendRefs:
    - name: dev-frontend
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /dev/api
    backendRefs:
    - name: dev-api
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /dev/backend
    backendRefs:
    - name: dev-backend
      port: 80
EOF
```

### STAGING Environment Routes

```bash
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: staging-routes
  namespace: staging
spec:
  parentRefs:
  - name: main-gateway
    namespace: default
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /staging/frontend
    backendRefs:
    - name: staging-frontend
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /staging/api
    backendRefs:
    - name: staging-api
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /staging/backend
    backendRefs:
    - name: staging-backend
      port: 80
EOF
```

### PROD Environment Routes

```bash
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: prod-routes
  namespace: prod
spec:
  parentRefs:
  - name: main-gateway
    namespace: default
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /prod/frontend
    backendRefs:
    - name: prod-frontend
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /prod/api
    backendRefs:
    - name: prod-api
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /prod/backend
    backendRefs:
    - name: prod-backend
      port: 80
EOF
```

### MONITORING Routes

```bash
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: monitoring-routes
  namespace: monitoring
spec:
  parentRefs:
  - name: main-gateway
    namespace: default
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /monitoring/prometheus
    backendRefs:
    - name: prometheus
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /monitoring/grafana
    backendRefs:
    - name: grafana
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /monitoring/alertmanager
    backendRefs:
    - name: alertmanager
      port: 80
EOF
```

---

## Step 8: Create ReferenceGrant for Cross-Namespace Access

```bash
# Allow default namespace Gateway to access services in other namespaces
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-gateway-dev
  namespace: dev
spec:
  from:
  - group: gateway.networking.k8s.io
    kind: HTTPRoute
    namespace: dev
  to:
  - group: ""
    kind: Service
---
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-gateway-staging
  namespace: staging
spec:
  from:
  - group: gateway.networking.k8s.io
    kind: HTTPRoute
    namespace: staging
  to:
  - group: ""
    kind: Service
---
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-gateway-prod
  namespace: prod
spec:
  from:
  - group: gateway.networking.k8s.io
    kind: HTTPRoute
    namespace: prod
  to:
  - group: ""
    kind: Service
---
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-gateway-monitoring
  namespace: monitoring
spec:
  from:
  - group: gateway.networking.k8s.io
    kind: HTTPRoute
    namespace: monitoring
  to:
  - group: ""
    kind: Service
EOF
```

---

## Step 9: Test the Routes

```bash
# Get the Gateway external IP
GATEWAY_IP=$(kubectl get gateway main-gateway -n default -o jsonpath='{.status.addresses[0].value}')
echo "Gateway IP: $GATEWAY_IP"

# Test DEV environment
echo "=== Testing DEV Environment ==="
curl http://$GATEWAY_IP/dev/frontend
curl http://$GATEWAY_IP/dev/api
curl http://$GATEWAY_IP/dev/backend

# Test STAGING environment
echo "=== Testing STAGING Environment ==="
curl http://$GATEWAY_IP/staging/frontend
curl http://$GATEWAY_IP/staging/api
curl http://$GATEWAY_IP/staging/backend

# Test PROD environment
echo "=== Testing PROD Environment ==="
curl http://$GATEWAY_IP/prod/frontend
curl http://$GATEWAY_IP/prod/api
curl http://$GATEWAY_IP/prod/backend

# Test MONITORING environment
echo "=== Testing MONITORING Environment ==="
curl http://$GATEWAY_IP/monitoring/prometheus
curl http://$GATEWAY_IP/monitoring/grafana
curl http://$GATEWAY_IP/monitoring/alertmanager
```

---

## Step 10: Advanced Routing - Traffic Splitting (Canary Deployment)

```bash
# Create canary deployment in prod
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prod-frontend-canary
  namespace: prod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prod-frontend-canary
  template:
    metadata:
      labels:
        app: prod-frontend-canary
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello from PRODUCTION Frontend CANARY! 🎯 Version 3.0 - New Features Testing"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: prod-frontend-canary
  namespace: prod
spec:
  selector:
    app: prod-frontend-canary
  ports:
  - port: 80
    targetPort: 5678
  type: ClusterIP
EOF

# Update HTTPRoute with traffic splitting (90% stable, 10% canary)
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: prod-routes
  namespace: prod
spec:
  parentRefs:
  - name: main-gateway
    namespace: default
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /prod/frontend
    backendRefs:
    - name: prod-frontend
      port: 80
      weight: 90
    - name: prod-frontend-canary
      port: 80
      weight: 10
  - matches:
    - path:
        type: PathPrefix
        value: /prod/api
    backendRefs:
    - name: prod-api
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /prod/backend
    backendRefs:
    - name: prod-backend
      port: 80
EOF

# Test canary - run multiple times to see both versions
echo "=== Testing Canary Deployment ==="
for i in {1..20}; do
  echo "Request $i:"
  curl http://$GATEWAY_IP/prod/frontend
  echo ""
done
```

---

## Step 11: Advanced Routing - Header-Based Routing

```bash
# Create a beta API version in staging
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: staging-api-beta
  namespace: staging
spec:
  replicas: 1
  selector:
    matchLabels:
      app: staging-api-beta
  template:
    metadata:
      labels:
        app: staging-api-beta
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=Hello from STAGING API BETA! 🔬 Experimental Features - Beta Users Only"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: staging-api-beta
  namespace: staging
spec:
  selector:
    app: staging-api-beta
  ports:
  - port: 80
    targetPort: 5678
  type: ClusterIP
EOF

# Update HTTPRoute with header-based routing
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: staging-routes
  namespace: staging
spec:
  parentRefs:
  - name: main-gateway
    namespace: default
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /staging/api
      headers:
      - type: Exact
        name: X-Beta-User
        value: "true"
    backendRefs:
    - name: staging-api-beta
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /staging/api
    backendRefs:
    - name: staging-api
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /staging/frontend
    backendRefs:
    - name: staging-frontend
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /staging/backend
    backendRefs:
    - name: staging-backend
      port: 80
EOF

# Test header-based routing
echo "=== Testing Header-Based Routing ==="
echo "Normal user (regular API):"
curl http://$GATEWAY_IP/staging/api

echo -e "\nBeta user (beta API):"
curl -H "X-Beta-User: true" http://$GATEWAY_IP/staging/api
```

---

## Step 12: Monitoring and Observability

```bash
# Check HTTPRoute status
kubectl get httproutes --all-namespaces

# Describe Gateway to see routes
kubectl describe gateway main-gateway -n default

# Check all routes details
kubectl describe httproute -n dev
kubectl describe httproute -n staging
kubectl describe httproute -n prod
kubectl describe httproute -n monitoring

# Check Istio components
kubectl get pods -n aks-istio-system

# View Istio gateway logs
kubectl logs -n aks-istio-system -l app=istiod --tail=50
```

---

## Step 13: Comprehensive Verification

```bash
# Verification script
echo "=== NAMESPACE VERIFICATION ==="
kubectl get ns | grep -E "dev|staging|prod|monitoring"

echo -e "\n=== DEPLOYMENTS ==="
kubectl get deployments --all-namespaces | grep -E "dev|staging|prod|monitoring"

echo -e "\n=== SERVICES ==="
kubectl get svc --all-namespaces | grep -E "dev|staging|prod|monitoring"

echo -e "\n=== GATEWAY STATUS ==="
kubectl get gateway -A

echo -e "\n=== GATEWAY CLASS ==="
kubectl get gatewayclass

echo -e "\n=== HTTP ROUTES ==="
kubectl get httproutes -A

echo -e "\n=== REFERENCE GRANTS ==="
kubectl get referencegrants -A

echo -e "\n=== POD STATUS BY NAMESPACE ==="
for ns in dev staging prod monitoring; do
  echo "--- $ns namespace ---"
  kubectl get pods -n $ns -o wide
done

echo -e "\n=== GATEWAY EXTERNAL IP ==="
GATEWAY_IP=$(kubectl get gateway main-gateway -n default -o jsonpath='{.status.addresses[0].value}')
echo "Gateway IP: $GATEWAY_IP"

echo -e "\n=== QUICK CONNECTIVITY TEST ==="
curl -s http://$GATEWAY_IP/dev/frontend | head -n 1
curl -s http://$GATEWAY_IP/staging/api | head -n 1
curl -s http://$GATEWAY_IP/prod/backend | head -n 1
curl -s http://$GATEWAY_IP/monitoring/prometheus | head -n 1
```

---

## Step 14: Deploy gRPC Application with GRPCRoute

### Create gRPC Namespace and Deploy gRPC Services

```bash
# Create gRPC namespace
kubectl create namespace grpc-services

# Deploy gRPC Hello Service
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grpc-hello-service
  namespace: grpc-services
spec:
  replicas: 2
  selector:
    matchLabels:
      app: grpc-hello-service
  template:
    metadata:
      labels:
        app: grpc-hello-service
    spec:
      containers:
      - name: grpc-server
        image: docker.io/grpc/helloworld:1.0
        ports:
        - containerPort: 50051
          name: grpc
---
apiVersion: v1
kind: Service
metadata:
  name: grpc-hello-service
  namespace: grpc-services
spec:
  selector:
    app: grpc-hello-service
  ports:
  - port: 50051
    targetPort: 50051
    name: grpc
  type: ClusterIP
EOF

# Deploy gRPC Calculator Service
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grpc-calculator-service
  namespace: grpc-services
spec:
  replicas: 2
  selector:
    matchLabels:
      app: grpc-calculator-service
  template:
    metadata:
      labels:
        app: grpc-calculator-service
    spec:
      containers:
      - name: grpc-server
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=gRPC Calculator Service - Add, Subtract, Multiply, Divide"
        ports:
        - containerPort: 5678
          name: grpc
---
apiVersion: v1
kind: Service
metadata:
  name: grpc-calculator-service
  namespace: grpc-services
spec:
  selector:
    app: grpc-calculator-service
  ports:
  - port: 50052
    targetPort: 5678
    name: grpc
  type: ClusterIP
EOF

# Deploy gRPC User Service
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grpc-user-service
  namespace: grpc-services
spec:
  replicas: 2
  selector:
    matchLabels:
      app: grpc-user-service
  template:
    metadata:
      labels:
        app: grpc-user-service
    spec:
      containers:
      - name: grpc-server
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=gRPC User Service - GetUser, CreateUser, UpdateUser, DeleteUser"
        ports:
        - containerPort: 5678
          name: grpc
---
apiVersion: v1
kind: Service
metadata:
  name: grpc-user-service
  namespace: grpc-services
spec:
  selector:
    app: grpc-user-service
  ports:
  - port: 50053
    targetPort: 5678
    name: grpc
  type: ClusterIP
EOF
```

### Create Gateway for gRPC Traffic

```bash
# Create a separate Gateway for gRPC (or use the existing one with additional listener)
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: grpc-gateway
  namespace: default
spec:
  gatewayClassName: istio-gateway
  listeners:
  - name: grpc
    protocol: HTTP
    port: 8080
    allowedRoutes:
      namespaces:
        from: All
      kinds:
      - group: gateway.networking.k8s.io
        kind: GRPCRoute
EOF

# Wait for Gateway to be ready
kubectl wait --for=condition=Programmed gateway/grpc-gateway -n default --timeout=300s

# Get Gateway external IP
kubectl get gateway grpc-gateway -n default
```

### Create GRPCRoutes

```bash
# Create GRPCRoute for Hello Service
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GRPCRoute
metadata:
  name: grpc-hello-route
  namespace: grpc-services
spec:
  parentRefs:
  - name: grpc-gateway
    namespace: default
  hostnames:
  - "grpc.example.com"
  rules:
  - matches:
    - method:
        service: helloworld.Greeter
    backendRefs:
    - name: grpc-hello-service
      port: 50051
EOF

# Create GRPCRoute for Calculator Service
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GRPCRoute
metadata:
  name: grpc-calculator-route
  namespace: grpc-services
spec:
  parentRefs:
  - name: grpc-gateway
    namespace: default
  hostnames:
  - "grpc.example.com"
  rules:
  - matches:
    - method:
        service: calculator.Calculator
    backendRefs:
    - name: grpc-calculator-service
      port: 50052
EOF

# Create GRPCRoute for User Service with method-level routing
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GRPCRoute
metadata:
  name: grpc-user-route
  namespace: grpc-services
spec:
  parentRefs:
  - name: grpc-gateway
    namespace: default
  hostnames:
  - "grpc.example.com"
  rules:
  - matches:
    - method:
        service: userservice.UserService
        method: GetUser
    backendRefs:
    - name: grpc-user-service
      port: 50053
  - matches:
    - method:
        service: userservice.UserService
        method: CreateUser
    backendRefs:
    - name: grpc-user-service
      port: 50053
  - matches:
    - method:
        service: userservice.UserService
    backendRefs:
    - name: grpc-user-service
      port: 50053
EOF
```

### Create ReferenceGrant for gRPC Namespace

```bash
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-grpc-gateway
  namespace: grpc-services
spec:
  from:
  - group: gateway.networking.k8s.io
    kind: GRPCRoute
    namespace: grpc-services
  to:
  - group: ""
    kind: Service
EOF
```

### Verify gRPC Setup

```bash
# Check gRPC namespace resources
echo "=== gRPC Services Namespace ==="
kubectl get all -n grpc-services

# Check GRPCRoutes
echo -e "\n=== GRPCRoutes ==="
kubectl get grpcroutes -n grpc-services

# Describe GRPCRoutes for details
echo -e "\n=== GRPCRoute Details ==="
kubectl describe grpcroute -n grpc-services

# Check gRPC Gateway
echo -e "\n=== gRPC Gateway ==="
kubectl get gateway grpc-gateway -n default
kubectl describe gateway grpc-gateway -n default

# Get Gateway external IP
GRPC_GATEWAY_IP=$(kubectl get gateway grpc-gateway -n default -o jsonpath='{.status.addresses[0].value}')
echo -e "\ngRPC Gateway IP: $GRPC_GATEWAY_IP"
```

### Test gRPC Services (using grpcurl)

```bash
# Install grpcurl if not already installed
# For Ubuntu/Debian:
# sudo apt-get install grpcurl
# For macOS:
# brew install grpcurl

# Get the gRPC Gateway IP
GRPC_GATEWAY_IP=$(kubectl get gateway grpc-gateway -n default -o jsonpath='{.status.addresses[0].value}')

# Test Hello Service (if using real gRPC helloworld image)
grpcurl -plaintext \
  -authority grpc.example.com \
  -d '{"name": "World"}' \
  ${GRPC_GATEWAY_IP}:8080 \
  helloworld.Greeter/SayHello

# List available services
grpcurl -plaintext \
  -authority grpc.example.com \
  ${GRPC_GATEWAY_IP}:8080 \
  list

# Test with custom header
grpcurl -plaintext \
  -authority grpc.example.com \
  -H "X-User-ID: 12345" \
  -d '{"name": "Kubernetes"}' \
  ${GRPC_GATEWAY_IP}:8080 \
  helloworld.Greeter/SayHello
```

### Alternative: Simple gRPC Test Without grpcurl

If you don't have grpcurl, create a test pod:

```bash
# Deploy a gRPC client test pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: grpc-client-test
  namespace: grpc-services
spec:
  containers:
  - name: grpc-client
    image: fullstorydev/grpcurl:latest
    command: ["/bin/sh"]
    args: ["-c", "sleep 3600"]
EOF

# Wait for pod to be ready
kubectl wait --for=condition=Ready pod/grpc-client-test -n grpc-services --timeout=60s

# Test from inside the cluster
kubectl exec -it grpc-client-test -n grpc-services -- \
  grpcurl -plaintext \
  grpc-hello-service.grpc-services.svc.cluster.local:50051 \
  list

# Test through the gateway
kubectl exec -it grpc-client-test -n grpc-services -- \
  grpcurl -plaintext \
  -authority grpc.example.com \
  grpc-gateway.default.svc.cluster.local:8080 \
  list
```

### Advanced: Traffic Splitting for gRPC

```bash
# Deploy a v2 version of the hello service
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grpc-hello-service-v2
  namespace: grpc-services
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grpc-hello-service-v2
      version: v2
  template:
    metadata:
      labels:
        app: grpc-hello-service-v2
        version: v2
    spec:
      containers:
      - name: grpc-server
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=gRPC Hello Service V2 - Enhanced Features!"
        ports:
        - containerPort: 5678
          name: grpc
---
apiVersion: v1
kind: Service
metadata:
  name: grpc-hello-service-v2
  namespace: grpc-services
spec:
  selector:
    app: grpc-hello-service-v2
  ports:
  - port: 50051
    targetPort: 5678
    name: grpc
  type: ClusterIP
EOF

# Update GRPCRoute with traffic splitting (80% v1, 20% v2)
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GRPCRoute
metadata:
  name: grpc-hello-route
  namespace: grpc-services
spec:
  parentRefs:
  - name: grpc-gateway
    namespace: default
  hostnames:
  - "grpc.example.com"
  rules:
  - matches:
    - method:
        service: helloworld.Greeter
    backendRefs:
    - name: grpc-hello-service
      port: 50051
      weight: 80
    - name: grpc-hello-service-v2
      port: 50051
      weight: 20
EOF
```

### Advanced: Header-Based gRPC Routing

```bash
# Create a premium user service
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grpc-user-service-premium
  namespace: grpc-services
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grpc-user-service-premium
  template:
    metadata:
      labels:
        app: grpc-user-service-premium
    spec:
      containers:
      - name: grpc-server
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=gRPC User Service PREMIUM - Priority Support & Advanced Features"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: grpc-user-service-premium
  namespace: grpc-services
spec:
  selector:
    app: grpc-user-service-premium
  ports:
  - port: 50053
    targetPort: 5678
  type: ClusterIP
EOF

# Update GRPCRoute with header-based routing
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GRPCRoute
metadata:
  name: grpc-user-route
  namespace: grpc-services
spec:
  parentRefs:
  - name: grpc-gateway
    namespace: default
  hostnames:
  - "grpc.example.com"
  rules:
  - matches:
    - method:
        service: userservice.UserService
      headers:
      - type: Exact
        name: X-User-Tier
        value: premium
    backendRefs:
    - name: grpc-user-service-premium
      port: 50053
  - matches:
    - method:
        service: userservice.UserService
    backendRefs:
    - name: grpc-user-service
      port: 50053
EOF

# Test with header
# grpcurl -plaintext \
#   -authority grpc.example.com \
#   -H "X-User-Tier: premium" \
#   ${GRPC_GATEWAY_IP}:8080 \
#   userservice.UserService/GetUser
```

### Verification Commands for gRPC

```bash
# Complete verification
echo "=== gRPC NAMESPACE ==="
kubectl get ns grpc-services

echo -e "\n=== gRPC DEPLOYMENTS ==="
kubectl get deployments -n grpc-services

echo -e "\n=== gRPC SERVICES ==="
kubectl get svc -n grpc-services

echo -e "\n=== gRPC PODS ==="
kubectl get pods -n grpc-services

echo -e "\n=== GRPC GATEWAY ==="
kubectl get gateway grpc-gateway -n default

echo -e "\n=== GRPC ROUTES ==="
kubectl get grpcroutes -n grpc-services

echo -e "\n=== GRPC ROUTE DETAILS ==="
kubectl describe grpcroute -n grpc-services

echo -e "\n=== REFERENCE GRANTS ==="
kubectl get referencegrants -n grpc-services

echo -e "\n=== GATEWAY EXTERNAL IP ==="
GRPC_GATEWAY_IP=$(kubectl get gateway grpc-gateway -n default -o jsonpath='{.status.addresses[0].value}')
echo "gRPC Gateway IP: $GRPC_GATEWAY_IP"
echo "gRPC Gateway Port: 8080"
```

### Key Features of GRPCRoute

1. **Service-Level Routing**: Route based on gRPC service names
2. **Method-Level Routing**: Route based on specific gRPC methods
3. **Header-Based Routing**: Route based on gRPC metadata headers
4. **Traffic Splitting**: Canary deployments for gRPC services
5. **Cross-Namespace**: Services can be in different namespaces
6. **Load Balancing**: Automatic load balancing across replicas

### GRPCRoute vs HTTPRoute Differences

| Feature | HTTPRoute | GRPCRoute |
|---------|-----------|-----------|
| **Protocol** | HTTP/1.1, HTTP/2 | HTTP/2 (gRPC) |
| **Matching** | Path, headers, query params | Service, method, headers |
| **Use Case** | REST APIs, web apps | gRPC microservices |
| **Port** | 80, 443 | 50051, 8080, custom |
| **Content-Type** | Any | application/grpc |

---

## Step 15: Performance Testing with k6

### Overview
We'll use k6 to perform comprehensive performance testing on our Gateway API infrastructure:
1. **Load Testing** - Sustained load to understand system behavior
2. **Stress Testing** - Push beyond normal capacity to find breaking points
3. **Spike Testing** - Sudden traffic increases to test elasticity
4. **Endurance (Soak) Testing** - Long-duration tests for memory leaks
5. **Scalability Testing** - Test with increasing load patterns

### Install k6

```bash
# Install k6 on Ubuntu/Debian
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6

# Verify installation
k6 version

# Alternative: Use Docker
# docker pull grafana/k6:latest
```

### Prepare Environment Variables

```bash
# Get Gateway IPs
export GATEWAY_IP=$(kubectl get gateway main-gateway -n default -o jsonpath='{.status.addresses[0].value}')
export GRPC_GATEWAY_IP=$(kubectl get gateway grpc-gateway -n default -o jsonpath='{.status.addresses[0].value}')

echo "HTTP Gateway IP: $GATEWAY_IP"
echo "gRPC Gateway IP: $GRPC_GATEWAY_IP"

# Create directory for k6 scripts
mkdir -p ~/k6-tests
cd ~/k6-tests
```

---

### Test 1: Load Testing - Baseline Performance

**Goal**: Establish baseline performance under normal load

```bash
# Create load test script
cat > load-test.js << 'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '2m', target: 50 },   // Ramp up to 50 users
    { duration: '5m', target: 50 },   // Stay at 50 users for 5 minutes
    { duration: '2m', target: 100 },  // Ramp up to 100 users
    { duration: '5m', target: 100 },  // Stay at 100 users
    { duration: '2m', target: 0 },    // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% of requests should be below 500ms
    http_req_failed: ['rate<0.01'],    // Error rate should be less than 1%
    errors: ['rate<0.1'],
  },
};

const BASE_URL = `http://${__ENV.GATEWAY_IP}`;

const scenarios = [
  { path: '/dev/frontend', name: 'DEV Frontend' },
  { path: '/dev/api', name: 'DEV API' },
  { path: '/staging/frontend', name: 'Staging Frontend' },
  { path: '/prod/frontend', name: 'PROD Frontend' },
  { path: '/prod/api', name: 'PROD API' },
  { path: '/monitoring/prometheus', name: 'Prometheus' },
];

export default function () {
  // Randomly select an endpoint
  const scenario = scenarios[Math.floor(Math.random() * scenarios.length)];
  
  const res = http.get(`${BASE_URL}${scenario.path}`, {
    tags: { name: scenario.name },
  });

  // Check response
  const checkRes = check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
    'response has content': (r) => r.body.length > 0,
  });

  errorRate.add(!checkRes);

  sleep(1); // Think time between requests
}
EOF

# Run load test
k6 run load-test.js
```

**Expected Metrics:**
- Response time percentiles (p50, p95, p99)
- Request rate (requests/second)
- Error rate
- Connection times

---

### Test 2: Stress Testing - Find Breaking Point

**Goal**: Push system beyond normal capacity to identify limits

```bash
# Create stress test script
cat > stress-test.js << 'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Counter } from 'k6/metrics';

const errorRate = new Rate('errors');
const successfulRequests = new Counter('successful_requests');

export const options = {
  stages: [
    { duration: '2m', target: 100 },   // Ramp up to 100 users
    { duration: '5m', target: 100 },   // Stay at 100
    { duration: '2m', target: 200 },   // Ramp up to 200
    { duration: '5m', target: 200 },   // Stay at 200
    { duration: '2m', target: 300 },   // Ramp up to 300
    { duration: '5m', target: 300 },   // Stay at 300
    { duration: '2m', target: 400 },   // Ramp up to 400 (stress point)
    { duration: '5m', target: 400 },   // Stay at 400
    { duration: '5m', target: 0 },     // Ramp down gradually
  ],
  thresholds: {
    http_req_duration: ['p(99)<3000'],  // More lenient during stress
    errors: ['rate<0.5'],                // Accept up to 50% errors at peak
  },
};

const BASE_URL = `http://${__ENV.GATEWAY_IP}`;

export default function () {
  const endpoints = [
    '/dev/frontend',
    '/dev/api',
    '/staging/api',
    '/prod/frontend',
    '/prod/api',
  ];
  
  const endpoint = endpoints[Math.floor(Math.random() * endpoints.length)];
  
  const res = http.get(`${BASE_URL}${endpoint}`, {
    timeout: '10s',
  });

  const success = check(res, {
    'status is 200': (r) => r.status === 200,
  });

  if (success) {
    successfulRequests.add(1);
  } else {
    errorRate.add(1);
    console.log(`Failed request to ${endpoint}: ${res.status}`);
  }

  sleep(0.5); // Reduced sleep for more aggressive load
}

export function handleSummary(data) {
  return {
    'stress-test-summary.json': JSON.stringify(data),
    stdout: textSummary(data, { indent: ' ', enableColors: true }),
  };
}
EOF

# Run stress test
k6 run stress-test.js

# Monitor pods during stress test (in another terminal)
watch kubectl top pods -n dev
watch kubectl top pods -n prod
```

---

### Test 3: Spike Testing - Sudden Traffic Surge

**Goal**: Test system resilience to sudden traffic spikes

```bash
# Create spike test script
cat > spike-test.js << 'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '1m', target: 10 },    // Normal load
    { duration: '30s', target: 500 },  // SPIKE! Sudden increase
    { duration: '3m', target: 500 },   // Stay at spike level
    { duration: '30s', target: 10 },   // Return to normal
    { duration: '2m', target: 10 },    // Recovery period
    { duration: '30s', target: 800 },  // Second bigger spike
    { duration: '3m', target: 800 },   // Stay at spike
    { duration: '1m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'],
    errors: ['rate<0.3'],
  },
};

const BASE_URL = `http://${__ENV.GATEWAY_IP}`;

export default function () {
  const paths = [
    '/prod/frontend',
    '/prod/api',
    '/prod/backend',
  ];
  
  const path = paths[Math.floor(Math.random() * paths.length)];
  
  const res = http.get(`${BASE_URL}${path}`, {
    tags: { endpoint: path },
  });

  const success = check(res, {
    'status is 200': (r) => r.status === 200,
    'response time OK': (r) => r.timings.duration < 2000,
  });

  errorRate.add(!success);
  
  sleep(Math.random() * 2); // Variable think time
}
EOF

# Run spike test
k6 run spike-test.js

# Watch HPA scaling (in another terminal)
watch kubectl get hpa -A
watch kubectl get pods -n prod
```

---

### Test 4: Endurance (Soak) Testing - Long Duration

**Goal**: Identify memory leaks and resource exhaustion over time

```bash
# Create endurance test script
cat > endurance-test.js << 'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const responseTime = new Trend('response_time');

export const options = {
  stages: [
    { duration: '5m', target: 50 },    // Ramp up
    { duration: '3h', target: 50 },    // Soak at 50 users for 3 hours
    { duration: '5m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000'],
    errors: ['rate<0.05'],
    response_time: ['p(99)<2000'],
  },
};

const BASE_URL = `http://${__ENV.GATEWAY_IP}`;

const endpoints = [
  { path: '/dev/frontend', weight: 2 },
  { path: '/dev/api', weight: 3 },
  { path: '/staging/frontend', weight: 2 },
  { path: '/staging/api', weight: 3 },
  { path: '/prod/frontend', weight: 4 },
  { path: '/prod/api', weight: 5 },
  { path: '/prod/backend', weight: 3 },
  { path: '/monitoring/prometheus', weight: 1 },
  { path: '/monitoring/grafana', weight: 1 },
];

function selectWeightedEndpoint() {
  const totalWeight = endpoints.reduce((sum, e) => sum + e.weight, 0);
  let random = Math.random() * totalWeight;
  
  for (const endpoint of endpoints) {
    if (random < endpoint.weight) {
      return endpoint.path;
    }
    random -= endpoint.weight;
  }
  return endpoints[0].path;
}

export default function () {
  const endpoint = selectWeightedEndpoint();
  
  const startTime = Date.now();
  const res = http.get(`${BASE_URL}${endpoint}`);
  const duration = Date.now() - startTime;
  
  responseTime.add(duration);

  const success = check(res, {
    'status is 200': (r) => r.status === 200,
    'has content': (r) => r.body && r.body.length > 0,
  });

  errorRate.add(!success);
  
  // Log every 1000 requests to track progress
  if (__ITER % 1000 === 0) {
    console.log(`Iteration ${__ITER}: ${endpoint} - ${res.status} - ${duration}ms`);
  }

  sleep(2); // Realistic user think time
}
EOF

# Run endurance test (WARNING: This runs for 3+ hours!)
k6 run endurance-test.js

# Monitor memory usage during soak test (in another terminal)
# Check every 15 minutes
watch -n 900 'kubectl top nodes && kubectl top pods -A'
```

---

### Test 5: Scalability Testing - Progressive Load Increase

**Goal**: Validate auto-scaling behavior and identify scalability limits

```bash
# First, enable HPA for your deployments
cat > enable-hpa.sh << 'EOF'
#!/bin/bash

# Enable HPA for dev namespace
kubectl autoscale deployment dev-frontend -n dev --cpu-percent=70 --min=2 --max=10
kubectl autoscale deployment dev-api -n dev --cpu-percent=70 --min=2 --max=10
kubectl autoscale deployment dev-backend -n dev --cpu-percent=70 --min=2 --max=10

# Enable HPA for staging namespace
kubectl autoscale deployment staging-frontend -n staging --cpu-percent=70 --min=2 --max=10
kubectl autoscale deployment staging-api -n staging --cpu-percent=70 --min=2 --max=10
kubectl autoscale deployment staging-backend -n staging --cpu-percent=70 --min=2 --max=10

# Enable HPA for prod namespace (more replicas)
kubectl autoscale deployment prod-frontend -n prod --cpu-percent=70 --min=3 --max=20
kubectl autoscale deployment prod-api -n prod --cpu-percent=70 --min=3 --max=20
kubectl autoscale deployment prod-backend -n prod --cpu-percent=70 --min=3 --max=20

# Enable HPA for monitoring namespace
kubectl autoscale deployment prometheus -n monitoring --cpu-percent=70 --min=1 --max=5
kubectl autoscale deployment grafana -n monitoring --cpu-percent=70 --min=1 --max=5
kubectl autoscale deployment alertmanager -n monitoring --cpu-percent=70 --min=1 --max=5

echo "HPA enabled for all deployments"
kubectl get hpa -A
EOF

chmod +x enable-hpa.sh
./enable-hpa.sh

# Create scalability test script
cat > scalability-test.js << 'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Counter } from 'k6/metrics';

const errorRate = new Rate('errors');
const requestCount = new Counter('requests');

export const options = {
  stages: [
    // Progressive load increase to test scaling
    { duration: '3m', target: 25 },    // Phase 1: 25 users
    { duration: '5m', target: 25 },    // Sustain
    { duration: '3m', target: 50 },    // Phase 2: 50 users
    { duration: '5m', target: 50 },    // Sustain
    { duration: '3m', target: 100 },   // Phase 3: 100 users
    { duration: '5m', target: 100 },   // Sustain
    { duration: '3m', target: 200 },   // Phase 4: 200 users
    { duration: '5m', target: 200 },   // Sustain
    { duration: '3m', target: 300 },   // Phase 5: 300 users
    { duration: '5m', target: 300 },   // Sustain
    { duration: '3m', target: 500 },   // Phase 6: 500 users (peak)
    { duration: '5m', target: 500 },   // Sustain at peak
    { duration: '5m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<1500'],
    errors: ['rate<0.1'],
  },
};

const BASE_URL = `http://${__ENV.GATEWAY_IP}`;

const environments = [
  { prefix: '/dev', weight: 2 },
  { prefix: '/staging', weight: 2 },
  { prefix: '/prod', weight: 5 },
  { prefix: '/monitoring', weight: 1 },
];

const services = ['frontend', 'api', 'backend'];

export default function () {
  // Select environment based on weight
  const totalWeight = environments.reduce((sum, e) => sum + e.weight, 0);
  let random = Math.random() * totalWeight;
  let selectedEnv = environments[0];
  
  for (const env of environments) {
    if (random < env.weight) {
      selectedEnv = env;
      break;
    }
    random -= env.weight;
  }
  
  // Select random service
  const service = services[Math.floor(Math.random() * services.length)];
  const path = `${selectedEnv.prefix}/${service}`;
  
  const res = http.get(`${BASE_URL}${path}`, {
    tags: { 
      environment: selectedEnv.prefix,
      service: service,
      phase: __VU < 50 ? 'low' : __VU < 150 ? 'medium' : 'high'
    },
  });

  requestCount.add(1);

  const success = check(res, {
    'status is 200': (r) => r.status === 200,
    'response time acceptable': (r) => r.timings.duration < 2000,
  });

  errorRate.add(!success);
  
  sleep(1);
}

export function handleSummary(data) {
  console.log('=== Scalability Test Summary ===');
  console.log(`Total Requests: ${data.metrics.requests.values.count}`);
  console.log(`Error Rate: ${(data.metrics.errors.values.rate * 100).toFixed(2)}%`);
  console.log(`Avg Response Time: ${data.metrics.http_req_duration.values.avg.toFixed(2)}ms`);
  console.log(`P95 Response Time: ${data.metrics['http_req_duration{p(95)}']}ms`);
  
  return {
    'scalability-test-results.json': JSON.stringify(data),
  };
}
EOF

# Run scalability test
k6 run scalability-test.js

# Monitor HPA and pod scaling in real-time (another terminal)
watch -n 5 'echo "=== HPA Status ===" && kubectl get hpa -A && echo "" && echo "=== Pod Counts ===" && kubectl get pods -A | grep -E "dev-|staging-|prod-|prometheus|grafana" | wc -l'
```

---

### Test 6: Mixed Workload Testing

**Goal**: Simulate realistic mixed traffic patterns

```bash
# Create mixed workload test
cat > mixed-workload-test.js << 'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { SharedArray } from 'k6/data';

const scenarios = new SharedArray('scenarios', function () {
  return [
    { type: 'light', duration: 0.5, requests: 1 },
    { type: 'medium', duration: 1, requests: 3 },
    { type: 'heavy', duration: 2, requests: 10 },
  ];
});

export const options = {
  scenarios: {
    light_users: {
      executor: 'constant-vus',
      vus: 20,
      duration: '10m',
      exec: 'lightUser',
    },
    medium_users: {
      executor: 'ramping-vus',
      startVUs: 10,
      stages: [
        { duration: '2m', target: 30 },
        { duration: '6m', target: 30 },
        { duration: '2m', target: 10 },
      ],
      exec: 'mediumUser',
    },
    heavy_users: {
      executor: 'ramping-vus',
      startVUs: 5,
      stages: [
        { duration: '3m', target: 15 },
        { duration: '4m', target: 15 },
        { duration: '3m', target: 5 },
      ],
      exec: 'heavyUser',
    },
  },
  thresholds: {
    'http_req_duration{user_type:light}': ['p(95)<500'],
    'http_req_duration{user_type:medium}': ['p(95)<1000'],
    'http_req_duration{user_type:heavy}': ['p(95)<2000'],
  },
};

const BASE_URL = `http://${__ENV.GATEWAY_IP}`;

// Light user - quick checks
export function lightUser() {
  const res = http.get(`${BASE_URL}/dev/frontend`, {
    tags: { user_type: 'light' },
  });
  
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(3);
}

// Medium user - browsing multiple pages
export function mediumUser() {
  const pages = ['/staging/frontend', '/staging/api', '/staging/backend'];
  
  for (const page of pages) {
    http.get(`${BASE_URL}${page}`, {
      tags: { user_type: 'medium' },
    });
    sleep(1);
  }
  sleep(2);
}

// Heavy user - intensive operations
export function heavyUser() {
  const endpoints = [
    '/prod/frontend',
    '/prod/api',
    '/prod/backend',
    '/monitoring/prometheus',
    '/monitoring/grafana',
  ];
  
  for (let i = 0; i < 10; i++) {
    const endpoint = endpoints[Math.floor(Math.random() * endpoints.length)];
    http.get(`${BASE_URL}${endpoint}`, {
      tags: { user_type: 'heavy' },
    });
    sleep(0.3);
  }
  sleep(1);
}
EOF

# Run mixed workload test
k6 run mixed-workload-test.js
```

---

### Monitoring During Tests

Create a monitoring script to track metrics during tests:

```bash
# Create monitoring script
cat > monitor-performance.sh << 'EOF'
#!/bin/bash

echo "=== Performance Monitoring Dashboard ==="
echo "Press Ctrl+C to stop"
echo ""

while true; do
  clear
  echo "=== $(date) ==="
  echo ""
  
  echo "--- Gateway Status ---"
  kubectl get gateway -A
  echo ""
  
  echo "--- Node Resource Usage ---"
  kubectl top nodes
  echo ""
  
  echo "--- Pod Resource Usage (Top 10) ---"
  kubectl top pods -A --sort-by=cpu | head -11
  echo ""
  
  echo "--- HPA Status ---"
  kubectl get hpa -A
  echo ""
  
  echo "--- Pod Count by Namespace ---"
  echo "DEV: $(kubectl get pods -n dev | grep -c Running) pods"
  echo "STAGING: $(kubectl get pods -n staging | grep -c Running) pods"
  echo "PROD: $(kubectl get pods -n prod | grep -c Running) pods"
  echo "MONITORING: $(kubectl get pods -n monitoring | grep -c Running) pods"
  echo "GRPC: $(kubectl get pods -n grpc-services | grep -c Running) pods"
  echo ""
  
  echo "--- Istio Gateway Pods ---"
  kubectl get pods -n aks-istio-system -l app=istiod
  echo ""
  
  sleep 10
done
EOF

chmod +x monitor-performance.sh

# Run monitoring in a separate terminal
./monitor-performance.sh
```

---

### Analyzing Results

Create a results analysis script:

```bash
# Create results analyzer
cat > analyze-results.sh << 'EOF'
#!/bin/bash

echo "=== K6 Performance Test Results Analysis ==="
echo ""

for file in *.json; do
  if [ -f "$file" ]; then
    echo "--- $file ---"
    
    # Extract key metrics using jq
    if command -v jq &> /dev/null; then
      echo "Total Requests: $(jq -r '.metrics.http_reqs.values.count' $file)"
      echo "Request Rate: $(jq -r '.metrics.http_reqs.values.rate' $file) req/s"
      echo "Failed Requests: $(jq -r '.metrics.http_req_failed.values.passes' $file)"
      echo "Avg Response Time: $(jq -r '.metrics.http_req_duration.values.avg' $file) ms"
      echo "P95 Response Time: $(jq -r '.metrics.http_req_duration.values["p(95)"]' $file) ms"
      echo "P99 Response Time: $(jq -r '.metrics.http_req_duration.values["p(99)"]' $file) ms"
    fi
    
    echo ""
  fi
done

echo "=== Recommendations ==="
echo "1. Check if P95 response times meet SLA requirements"
echo "2. Verify error rate is below acceptable threshold"
echo "3. Review resource utilization during peak load"
echo "4. Assess auto-scaling effectiveness"
echo "5. Identify bottlenecks from slowest endpoints"
EOF

chmod +x analyze-results.sh

# Install jq if not available
# sudo apt-get install jq

# Run analysis
./analyze-results.sh
```

---

### Quick Test Suite - Run All Tests

```bash
# Create a master test runner
cat > run-all-tests.sh << 'EOF'
#!/bin/bash

export GATEWAY_IP=$(kubectl get gateway main-gateway -n default -o jsonpath='{.status.addresses[0].value}')

if [ -z "$GATEWAY_IP" ]; then
  echo "Error: Could not get Gateway IP"
  exit 1
fi

echo "Gateway IP: $GATEWAY_IP"
echo "Starting comprehensive performance test suite..."
echo ""

tests=("load-test" "stress-test" "spike-test" "scalability-test" "mixed-workload-test")

for test in "${tests[@]}"; do
  echo "=========================================="
  echo "Running: $test"
  echo "=========================================="
  
  k6 run ${test}.js --out json=${test}-results.json
  
  echo ""
  echo "Completed: $test"
  echo "Waiting 2 minutes before next test..."
  sleep 120
done

echo ""
echo "All tests completed!"
echo "Run ./analyze-results.sh to see summary"
EOF

chmod +x run-all-tests.sh

# Run all tests (will take several hours)
./run-all-tests.sh
```

---

### Performance Testing Best Practices

1. **Baseline First**: Always establish baseline performance before optimization
2. **Monitor Resources**: Watch CPU, memory, network during tests
3. **Incremental Load**: Gradually increase load to identify breaking points
4. **Realistic Scenarios**: Mix different user behaviors and endpoints
5. **Soak Testing**: Run for extended periods to catch memory leaks
6. **Document Results**: Keep records of all test runs for comparison
7. **Test After Changes**: Re-run tests after infrastructure changes

### Expected Outcomes

After running these tests, you should be able to answer:
- ✅ What is the maximum sustainable load?
- ✅ How does the system behave under stress?
- ✅ Does auto-scaling work effectively?
- ✅ Are there any memory leaks over time?
- ✅ What are the response time percentiles?
- ✅ Which endpoints are bottlenecks?

---

## Step 16: Cleanup (When Done)

```bash
# Delete HTTPRoutes
kubectl delete httproutes --all -n dev
kubectl delete httproutes --all -n staging
kubectl delete httproutes --all -n prod
kubectl delete httproutes --all -n monitoring

# Delete ReferenceGrants
kubectl delete referencegrants --all -n dev
kubectl delete referencegrants --all -n staging
kubectl delete referencegrants --all -n prod
kubectl delete referencegrants --all -n monitoring

# Delete Gateway and GatewayClass
kubectl delete gateway main-gateway -n default
kubectl delete gatewayclass istio-gateway

# Delete namespaces (this will delete all resources in them)
kubectl delete namespace dev
kubectl delete namespace staging
kubectl delete namespace prod
kubectl delete namespace monitoring

# Delete AKS cluster
az aks delete --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --yes --no-wait

# Delete resource group
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

## Key Concepts Demonstrated

1. **Multi-Namespace Architecture**: Complete isolation between environments
2. **Gateway API with Istio**: Modern Kubernetes ingress using standard APIs
3. **Path-Based Routing**: Route traffic based on URL paths without hostname complications
4. **Cross-Namespace References**: Secure service access using ReferenceGrants
5. **Traffic Splitting**: Canary deployments with percentage-based routing (90/10 split)
6. **Header-Based Routing**: Route traffic based on HTTP headers for beta testing
7. **Simple Application**: Using http-echo eliminates nginx path configuration issues

## Why http-echo Works Better Than nginx

**http-echo advantages:**
- ✅ **No path configuration needed** - responds to ANY path automatically
- ✅ **Lightweight** - tiny container, fast startup
- ✅ **Simple** - one argument sets the response text
- ✅ **Port 5678** - listens on a single port, easy to configure
- ✅ **No 404 errors** - handles all routes without configuration

**nginx challenges we avoided:**
- ❌ Requires location blocks for each path
- ❌ Needs path rewriting with `alias` directive
- ❌ Complex configuration for multiple paths
- ❌ 404 errors when paths don't match filesystem

## Troubleshooting Tips

- If Gateway doesn't get an external IP, check Istio installation: `kubectl get svc -n aks-istio-system`
- Ensure Gateway API CRDs are installed: `kubectl api-resources | grep gateway`
- Verify ReferenceGrants exist for cross-namespace access
- Check pod logs: `kubectl logs -n <namespace> <pod-name>`
- Use `kubectl describe httproute <name> -n <namespace>` for detailed status
- Check Istio health: `kubectl get pods -n aks-istio-


