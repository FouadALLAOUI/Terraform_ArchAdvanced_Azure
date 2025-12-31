#!/bin/bash

echo "hello script of linux"

echo "This is AKS Lab Gateway API script."

## Step 1: Create AKS Cluster with Gateway API

# Set variables
RESOURCE_GROUP="rg-aks-gateway-lab"
CLUSTER_NAME="aks-gateway-demo"
LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS cluster with Gateway API addon
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 3 \
  --node-vm-size Standard_DS2_v2 \
  --enable-managed-identity \
  --network-plugin azure \
  --network-policy azure \
  --generate-ssh-keys

# Get credentials and overwrite existing config
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing

## Step 2: Enable Gateway API Addon

# Enable the Gateway API addon
az aks update \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --enable-gateway-api

# Verify Gateway API CRDs are installed
kubectl api-resources | grep gateway

#Expected output should include:
#- gatewayclasses
#- gateways
#- httproutes
#- referencegrants


## Step 3: Create Namespaces

# Create all four namespaces
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace prod
kubectl create namespace monitoring

# Verify namespaces
kubectl get namespaces


## Step 4: Deploy Applications to Each Namespace

### DEV Namespace - Applications

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
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: dev-frontend-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: dev-frontend-html
  namespace: dev
data:
  index.html: |
    DEV Environment - Frontend AppVersion 1.0
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
    targetPort: 80
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
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: dev-api-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: dev-api-html
  namespace: dev
data:
  index.html: |
    DEV Environment - API AppEndpoints: /users, /products
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
    targetPort: 80
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
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: dev-backend-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: dev-backend-html
  namespace: dev
data:
  index.html: |
    DEV Environment - Backend AppDatabase: Connected
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
    targetPort: 80
  type: ClusterIP
EOF


### STAGING Namespace - Applications

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
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: staging-frontend-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: staging-frontend-html
  namespace: staging
data:
  index.html: |
    STAGING Environment - Frontend AppVersion 1.5 - Testing
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
    targetPort: 80
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
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: staging-api-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: staging-api-html
  namespace: staging
data:
  index.html: |
    STAGING Environment - API AppTesting new endpoints
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
    targetPort: 80
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
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: staging-backend-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: staging-backend-html
  namespace: staging
data:
  index.html: |
    STAGING Environment - Backend AppStaging DB Connected
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
    targetPort: 80
  type: ClusterIP
EOF

### PROD Namespace - Applications

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
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: prod-frontend-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prod-frontend-html
  namespace: prod
data:
  index.html: |
    PRODUCTION Environment - Frontend AppVersion 2.0 - Stable
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
    targetPort: 80
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
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: prod-api-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prod-api-html
  namespace: prod
data:
  index.html: |
    PRODUCTION Environment - API AppLive API Endpoints
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
    targetPort: 80
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
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: prod-backend-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prod-backend-html
  namespace: prod
data:
  index.html: |
    PRODUCTION Environment - Backend AppProduction DB - High Availability
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
    targetPort: 80
  type: ClusterIP
EOF


### MONITORING Namespace - Applications

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
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: prometheus-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-html
  namespace: monitoring
data:
  index.html: |
    Prometheus MonitoringMetrics Collection Active
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
    targetPort: 80
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
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: grafana-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-html
  namespace: monitoring
data:
  index.html: |
    Grafana DashboardVisualization Platform
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
    targetPort: 80
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
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: alertmanager-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-html
  namespace: monitoring
data:
  index.html: |
    AlertManagerAlert Management System
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
    targetPort: 80
  type: ClusterIP
EOF


## Step 5: Verify All Deployments

# Check all deployments
kubectl get deployments --all-namespaces

# Check all services
kubectl get services --all-namespaces

# Check pods in each namespace
kubectl get pods -n dev
kubectl get pods -n staging
kubectl get pods -n prod
kubectl get pods -n monitoring


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
## Step 6: Create Gateway Class and Gateway
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

# Create GatewayClass
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: azure-application-gateway
spec:
  controllerName: azure.com/application-gateway
EOF

# Create Gateway
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main-gateway
  namespace: default
spec:
  gatewayClassName: azure-application-gateway
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

## Step 7: Create HTTPRoutes for All Applications

### DEV Environment Routes

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
  hostnames:
  - "dev.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /frontend
    backendRefs:
    - name: dev-frontend
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: dev-api
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /backend
    backendRefs:
    - name: dev-backend
      port: 80
EOF

### STAGING Environment Routes

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
  hostnames:
  - "staging.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /frontend
    backendRefs:
    - name: staging-frontend
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: staging-api
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /backend
    backendRefs:
    - name: staging-backend
      port: 80
EOF

### PROD Environment Routes

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
  hostnames:
  - "prod.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /frontend
    backendRefs:
    - name: prod-frontend
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: prod-api
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /backend
    backendRefs:
    - name: prod-backend
      port: 80
EOF

### MONITORING Routes

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
  hostnames:
  - "monitoring.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /prometheus
    backendRefs:
    - name: prometheus
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /grafana
    backendRefs:
    - name: grafana
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /alertmanager
    backendRefs:
    - name: alertmanager
      port: 80
EOF


## Step 8: Create ReferenceGrant for Cross-Namespace Access

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
    namespace: default
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
    namespace: default
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
    namespace: default
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
    namespace: default
  to:
  - group: ""
    kind: Service
EOF

## Step 9: Test the Routes

# Get the Gateway external IP
GATEWAY_IP=$(kubectl get gateway main-gateway -n default -o jsonpath='{.status.addresses[0].value}')
echo "Gateway IP: $GATEWAY_IP"

# Test DEV environment
curl -H "Host: dev.example.com" http://$GATEWAY_IP/frontend
curl -H "Host: dev.example.com" http://$GATEWAY_IP/api
curl -H "Host: dev.example.com" http://$GATEWAY_IP/backend

# Test STAGING environment
curl -H "Host: staging.example.com" http://$GATEWAY_IP/frontend
curl -H "Host: staging.example.com" http://$GATEWAY_IP/api
curl -H "Host: staging.example.com" http://$GATEWAY_IP/backend

# Test PROD environment
curl -H "Host: prod.example.com" http://$GATEWAY_IP/frontend
curl -H "Host: prod.example.com" http://$GATEWAY_IP/api
curl -H "Host: prod.example.com" http://$GATEWAY_IP/backend

# Test MONITORING environment
curl -H "Host: monitoring.example.com" http://$GATEWAY_IP/prometheus
curl -H "Host: monitoring.example.com" http://$GATEWAY_IP/grafana
curl -H "Host: monitoring.example.com" http://$GATEWAY_IP/alertmanager


## Step 10: Advanced Routing Examples

### Traffic Splitting (Canary Deployment)

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
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: prod-frontend-canary-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prod-frontend-canary-html
  namespace: prod
data:
  index.html: |
    PRODUCTION - Frontend CANARY v3.0New Features Testing
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
    targetPort: 80
  type: ClusterIP
EOF


# Update HTTPRoute with traffic splitting (90% to stable, 10% to canary)
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
  hostnames:
  - "prod.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /frontend
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
        value: /api
    backendRefs:
    - name: prod-api
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /backend
    backendRefs:
    - name: prod-backend
      port: 80
EOF

### Header-Based Routing

# Create beta version for staging
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: staging-beta-routes
  namespace: staging
spec:
  parentRefs:
  - name: main-gateway
    namespace: default
  hostnames:
  - "staging.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api
      headers:
      - name: X-Beta-User
        value: "true"
    backendRefs:
    - name: staging-api
      port: 80
EOF


## Step 11: Monitoring and Observability

# Check HTTPRoute status
kubectl get httproutes --all-namespaces

# Describe Gateway to see routes
kubectl describe gateway main-gateway -n default

# Check Gateway API events
kubectl get events -n default --sort-by='.lastTimestamp'

# View logs of gateway controller
kubectl logs -n kube-system -l app=gateway-controller --tail=100

## Step 12: Verification Commands

# Comprehensive verification script
echo "=== Namespaces ==="
kubectl get ns | grep -E "dev|staging|prod|monitoring"

echo -e "\n=== All Deployments ==="
kubectl get deployments --all-namespaces -o wide

echo -e "\n=== All Services ==="
kubectl get svc --all-namespaces -o wide

echo -e "\n=== Gateway Status ==="
kubectl get gateway -A

echo -e "\n=== HTTPRoutes ==="
kubectl get httproutes -A

echo -e "\n=== Pod Status by Namespace ==="
for ns in dev staging prod monitoring; do
  echo "--- $ns namespace ---"
  kubectl get pods -n $ns
done

## Step 13: Cleanup (When Done)

# Delete all resources
kubectl delete httproutes --all -n dev
kubectl delete httproutes --all -n staging
kubectl delete httproutes --all -n prod
kubectl delete httproutes --all -n monitoring

kubectl delete gateway main-gateway -n default
kubectl delete gatewayclass azure-application-gateway

# Delete namespaces (this will delete all resources in them)
kubectl delete namespace dev
kubectl delete namespace staging
kubectl delete namespace prod
kubectl delete namespace monitoring

# Delete AKS cluster
az aks delete --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --yes --no-wait

# Delete resource group
az group delete --name $RESOURCE_GROUP --yes --no-wait




