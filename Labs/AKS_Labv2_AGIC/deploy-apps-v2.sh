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
          cat > /work/index.html <<HTML
          <!DOCTYPE html>
          <html>
          <head>
              <title>${NAMESPACE} - ${APP_NAME}</title>
              <style>
                  body {
                      font-family: Arial, sans-serif;
                      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                      display: flex;
                      justify-content: center;
                      align-items: center;
                      height: 100vh;
                      margin: 0;
                  }
                  .container {
                      background: white;
                      padding: 40px;
                      border-radius: 10px;
                      box-shadow: 0 10px 25px rgba(0,0,0,0.2);
                      text-align: center;
                  }
                  h1 { color: #667eea; margin: 0 0 10px 0; }
                  h2 { color: #764ba2; margin: 0 0 20px 0; }
                  .info { 
                      background: #f5f5f5; 
                      padding: 15px; 
                      border-radius: 5px;
                      margin-top: 20px;
                  }
                  .label { font-weight: bold; color: #555; }
                  .value { color: #333; }
              </style>
          </head>
          <body>
              <div class="container">
                  <h1>🚀 AKS with AGIC v2</h1>
                  <h2>Separate VNets Architecture</h2>
                  <div class="info">
                      <div><span class="label">Namespace:</span> <span class="value">${NAMESPACE}</span></div>
                      <div><span class="label">Application:</span> <span class="value">${APP_NAME}</span></div>
                      <div><span class="label">Pod:</span> <span class="value">\$(hostname)</span></div>
                      <div><span class="label">Architecture:</span> <span class="value">App Gateway VNet ⟷ AKS VNet</span></div>
                  </div>
              </div>
          </body>
          </html>
HTML
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

echo "✓ All applications deployed successfully!"











