#!/bin/bash

# Array of namespaces
NAMESPACES=("dev" "staging" "prod" "shared")

# Function to deploy apps in a namespace
deploy_namespace_apps() {
  NAMESPACE=$1
  
  for APP_NUM in 1 2 3; do
    APP_NAME="app${APP_NUM}"
    
    echo "Deploying ${APP_NAME} in ${NAMESPACE}..."
    
    # Create deployment
    cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ${APP_NAME}
      env: ${NAMESPACE}
  template:
    metadata:
      labels:
        app: ${APP_NAME}
        env: ${NAMESPACE}
    spec:
      containers:
      - name: ${APP_NAME}
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      initContainers:
      - name: install
        image: busybox
        command:
        - sh
        - -c
        - |
          echo "<html><body><h1>Namespace: ${NAMESPACE}</h1><h2>App: ${APP_NAME}</h2><p>Pod: \$(hostname)</p></body></html>" > /work/index.html
        volumeMounts:
        - name: html
          mountPath: /work
      volumes:
      - name: html
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: ${APP_NAME}-service
  namespace: ${NAMESPACE}
spec:
  selector:
    app: ${APP_NAME}
    env: ${NAMESPACE}
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
EOF
  done
}

# Deploy apps to all namespaces
for NS in "${NAMESPACES[@]}"; do
  deploy_namespace_apps $NS
  echo "---"
done

echo "All applications deployed successfully!"