#!/bin/bash

NAMESPACES=("dev" "staging" "prod" "shared")

for NAMESPACE in "${NAMESPACES[@]}"; do
  echo "Creating Ingress for ${NAMESPACE}..."
  
  cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${NAMESPACE}-ingress
  namespace: ${NAMESPACE}
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
    appgw.ingress.kubernetes.io/use-private-ip: "false"
    appgw.ingress.kubernetes.io/backend-path-prefix: "/"
spec:
  rules:
  - http:
      paths:
      - path: /${NAMESPACE}/app1/*
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
      - path: /${NAMESPACE}/app2/*
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
      - path: /${NAMESPACE}/app3/*
        pathType: Prefix
        backend:
          service:
            name: app3-service
            port:
              number: 80
EOF
done

echo "✓ All Ingress resources created!"

