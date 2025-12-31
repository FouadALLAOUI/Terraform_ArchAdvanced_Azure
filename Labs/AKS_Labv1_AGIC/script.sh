#!/bin/bash

echo "hello script of linux"

# Set variables
RESOURCE_GROUP="rg-aks-agic-lab"
LOCATION="eastus"
AKS_NAME="aks-agic-cluster"
APPGW_NAME="appgw-aks-ingress"
VNET_NAME="vnet-aks"
AKS_SUBNET_NAME="subnet-aks"
APPGW_SUBNET_NAME="subnet-appgw"
PUBLIC_IP_NAME="pip-appgw"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create virtual network and subnets
# Create VNet
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --location $LOCATION

# Create AKS subnet
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $AKS_SUBNET_NAME \
  --address-prefix 10.0.1.0/24

# Create Application Gateway subnet
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $APPGW_SUBNET_NAME \
  --address-prefix 10.0.2.0/24

# Create public IP for Application Gateway
az network public-ip create \
  --resource-group $RESOURCE_GROUP \
  --name $PUBLIC_IP_NAME \
  --allocation-method Static \
  --sku Standard \
  --location $LOCATION

# Create Application Gateway
az network application-gateway create \
  --name $APPGW_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_v2 \
  --capacity 2 \
  --vnet-name $VNET_NAME \
  --subnet $APPGW_SUBNET_NAME \
  --public-ip-address $PUBLIC_IP_NAME \
  --priority 100


# Get subnet ID
AKS_SUBNET_ID=$(az network vnet subnet show \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $AKS_SUBNET_NAME \
  --query id -o tsv)

# Get Application Gateway ID
APPGW_ID=$(az network application-gateway show \
  --name $APPGW_NAME \
  --resource-group $RESOURCE_GROUP \
  --query id -o tsv)

# Install AKS CLI extension if not already installed
az extension list --output table

# Create AKS cluster with AGIC addon
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --location $LOCATION \
  --network-plugin azure \
  --vnet-subnet-id $AKS_SUBNET_ID \
  --enable-managed-identity \
  --node-count 2 \
  --node-vm-size Standard_DS2_v2 \
  --enable-addons ingress-appgw \
  --appgw-id $APPGW_ID \
  --service-cidr 10.1.0.0/16 \
  --dns-service-ip 10.1.0.10 \
  --generate-ssh-keys


az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --overwrite-existing

# Verify connection
kubectl get nodes

# Check AGIC deployment
kubectl get pods -n kube-system -l app=ingress-appgw

# View AGIC logs
AGIC_POD=$(kubectl get pods -n kube-system -l app=ingress-appgw -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n kube-system $AGIC_POD -f

# Create namespaces
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace prod
kubectl create namespace shared

chmod +x deploy-apps.sh
./deploy-apps.sh


# Check all pods
kubectl get pods --all-namespaces

# Check pods per namespace
kubectl get pods -n dev
kubectl get pods -n staging
kubectl get pods -n prod
kubectl get pods -n shared

# Check services
kubectl get svc --all-namespaces


chmod +x create-ingress.sh
./create-ingress.sh


# Verify ingress resources and configuration

# Check ingress resources
kubectl get ingress --all-namespaces

# Get detailed ingress info
kubectl describe ingress -n dev
kubectl describe ingress -n staging
kubectl describe ingress -n prod
kubectl describe ingress -n shared

# Wait for ingress to get an address (may take 2-5 minutes)
kubectl get ingress -n dev -w


# Get the public IP
APPGW_PUBLIC_IP=$(az network public-ip show \
  --resource-group $RESOURCE_GROUP \
  --name $PUBLIC_IP_NAME \
  --query ipAddress -o tsv)

echo "Application Gateway Public IP: $APPGW_PUBLIC_IP"


# Test dev namespace apps
curl http://$APPGW_PUBLIC_IP/dev/app1/
curl http://$APPGW_PUBLIC_IP/dev/app2/
curl http://$APPGW_PUBLIC_IP/dev/app3/

# Test staging namespace apps
curl http://$APPGW_PUBLIC_IP/staging/app1/
curl http://$APPGW_PUBLIC_IP/staging/app2/
curl http://$APPGW_PUBLIC_IP/staging/app3/

# Test prod namespace apps
curl http://$APPGW_PUBLIC_IP/prod/app1/
curl http://$APPGW_PUBLIC_IP/prod/app2/
curl http://$APPGW_PUBLIC_IP/prod/app3/

# Test shared namespace apps
curl http://$APPGW_PUBLIC_IP/shared/app1/
curl http://$APPGW_PUBLIC_IP/shared/app2/
curl http://$APPGW_PUBLIC_IP/shared/app3/


# Get AGIC pod name
AGIC_POD=$(kubectl get pods -n kube-system -l app=ingress-appgw -o jsonpath='{.items[0].metadata.name}')

# View AGIC logs
kubectl logs -n kube-system $AGIC_POD -f

# View backend pools
az network application-gateway address-pool list \
  --resource-group $RESOURCE_GROUP \
  --gateway-name $APPGW_NAME \
  --output table

# View HTTP settings
az network application-gateway http-settings list \
  --resource-group $RESOURCE_GROUP \
  --gateway-name $APPGW_NAME \
  --output table

# View rules
az network application-gateway rule list \
  --resource-group $RESOURCE_GROUP \
  --gateway-name $APPGW_NAME \
  --output table

# View listeners
az network application-gateway http-listener list \
  --resource-group $RESOURCE_GROUP \
  --gateway-name $APPGW_NAME \
  --output table

# Verify AGIC pod is running
kubectl get pods -n kube-system -l app=ingress-appgw

kubectl get cm -n kube-system ingress-appgw-config -o yaml

kubectl get endpoints -n dev
kubectl get endpoints -n staging
kubectl get endpoints -n prod
kubectl get endpoints -n shared

kubectl get events -n dev --sort-by='.lastTimestamp'

kubectl get events -n staging --sort-by='.lastTimestamp'

kubectl get events -n prod --sort-by='.lastTimestamp'

kubectl get events -n shared --sort-by='.lastTimestamp'

kubectl rollout restart deployment -n kube-system ingress-appgw-deployment



########
# Configure SSL/TLS with Key Vault and Application Gateway
########

# Key Vault and Certificate variables
KEYVAULT_NAME="kv-agic-lab-$RANDOM"  # Must be globally unique
CERT_NAME="agic-ssl-cert"
DNS_NAME="playing.rionostrada.com"  # Change this to your domain if you have one

# Create Key Vault
az keyvault create \
  --name $KEYVAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --enabled-for-template-deployment true

echo "Key Vault created: $KEYVAULT_NAME"

# Generate a self-signed certificate and store it in Key Vault

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -out agic-ssl-cert.crt \
  -keyout agic-ssl-cert.key \
  -subj "/CN=${DNS_NAME}/O=AGIC Lab/C=US"

# Convert to PFX format (required by Key Vault)
openssl pkcs12 -export \
  -out agic-ssl-cert.pfx \
  -inkey agic-ssl-cert.key \
  -in agic-ssl-cert.crt \
  -passout pass:

echo "Certificate generated: agic-ssl-cert.pfx"

# Import certificate to Key Vault
az keyvault certificate import \
  --vault-name $KEYVAULT_NAME \
  --name $CERT_NAME \
  --file agic-ssl-cert.pfx

echo "Certificate imported to Key Vault"

# Get the secret ID for the certificate
CERT_SECRET_ID=$(az keyvault certificate show \
  --vault-name $KEYVAULT_NAME \
  --name $CERT_NAME \
  --query sid -o tsv)

echo "Certificate Secret ID: $CERT_SECRET_ID"

# Get Application Gateway managed identity
APPGW_IDENTITY=$(az network application-gateway show \
  --name $APPGW_NAME \
  --resource-group $RESOURCE_GROUP \
  --query identity.principalId -o tsv)

# If no managed identity exists, enable it
if [ -z "$APPGW_IDENTITY" ]; then
  echo "Enabling managed identity for Application Gateway..."
  az network application-gateway identity assign \
    --gateway-name $APPGW_NAME \
    --resource-group $RESOURCE_GROUP \
    --identity [system]
  
  # Get the identity again
  APPGW_IDENTITY=$(az network application-gateway show \
    --name $APPGW_NAME \
    --resource-group $RESOURCE_GROUP \
    --query identity.principalId -o tsv)
fi

echo "Application Gateway Identity: $APPGW_IDENTITY"

# Grant Key Vault access to Application Gateway
az keyvault set-policy \
  --name $KEYVAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --object-id $APPGW_IDENTITY \
  --secret-permissions get list \
  --certificate-permissions get list

echo "Key Vault access granted to Application Gateway"

# Add the certificate from Key Vault to Application Gateway
az network application-gateway ssl-cert create \
  --gateway-name $APPGW_NAME \
  --resource-group $RESOURCE_GROUP \
  --name agic-ssl-certificate \
  --key-vault-secret-id $CERT_SECRET_ID

echo "SSL certificate added to Application Gateway"

# Get the frontend IP configuration name
FRONTEND_IP=$(az network application-gateway frontend-ip list \
  --gateway-name $APPGW_NAME \
  --resource-group $RESOURCE_GROUP \
  --query [0].name -o tsv)

# Get frontend port for HTTPS (create if doesn't exist)
az network application-gateway frontend-port create \
  --gateway-name $APPGW_NAME \
  --resource-group $RESOURCE_GROUP \
  --name https-port \
  --port 443 2>/dev/null || echo "Port 443 already exists"

# Create HTTPS listener
az network application-gateway http-listener create \
  --gateway-name $APPGW_NAME \
  --resource-group $RESOURCE_GROUP \
  --name https-listener \
  --frontend-ip $FRONTEND_IP \
  --frontend-port https-port \
  --ssl-cert agic-ssl-certificate

echo "HTTPS listener created"

# Update Ingress Resources for HTTPS
chmod +x update-ingress-https.sh
./update-ingress-https.sh


# Check Application Gateway SSL certificates
az network application-gateway ssl-cert list \
  --gateway-name $APPGW_NAME \
  --resource-group $RESOURCE_GROUP \
  --output table

# Check HTTPS listener
az network application-gateway http-listener list \
  --gateway-name $APPGW_NAME \
  --resource-group $RESOURCE_GROUP \
  --output table

# Verify ingress annotations
kubectl get ingress -n dev -o yaml | grep -A 5 annotations


# Get Application Gateway Public IP
APPGW_PUBLIC_IP=$(az network public-ip show \
  --resource-group $RESOURCE_GROUP \
  --name $PUBLIC_IP_NAME \
  --query ipAddress -o tsv)

echo "Testing HTTPS endpoints..."
echo "Application Gateway IP: $APPGW_PUBLIC_IP"

# Test with curl (use -k to ignore self-signed certificate warning)
curl -k https://$APPGW_PUBLIC_IP/dev/app1/
curl -k https://$APPGW_PUBLIC_IP/staging/app2/
curl -k https://$APPGW_PUBLIC_IP/prod/app3/

# Test HTTP to HTTPS redirect
curl -I http://$APPGW_PUBLIC_IP/dev/app1/

# Remove local certificate files
rm -f agic-ssl-cert.crt agic-ssl-cert.key agic-ssl-cert.pfx

echo "Local certificate files cleaned up"


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Alternative: Using a Trusted CA Certificate
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Wait for cert-manager to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n cert-manager --timeout=300s

cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com  # Change this
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: azure/application-gateway
EOF

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: dev-ingress
  namespace: dev
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
    cert-manager.io/cluster-issuer: letsencrypt-prod
    appgw.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - yourdomain.com
    secretName: tls-secret
  rules:
  - host: yourdomain.com
    http:
      paths:
      - path: /dev/app1/*
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
EOF


# View backend pools
az network application-gateway address-pool list \
  --resource-group $RESOURCE_GROUP \
  --gateway-name $APPGW_NAME \
  --output table

# View HTTP settings
az network application-gateway http-settings list \
  --resource-group $RESOURCE_GROUP \
  --gateway-name $APPGW_NAME \
  --output table

# View rules
az network application-gateway rule list \
  --resource-group $RESOURCE_GROUP \
  --gateway-name $APPGW_NAME \
  --output table

# View SSL certificates
az network application-gateway ssl-cert list \
  --resource-group $RESOURCE_GROUP \
  --gateway-name $APPGW_NAME \
  --output table


kubectl get pods -n kube-system -l app=ingress-appgw

kubectl get cm -n kube-system ingress-appgw-config -o yaml

kubectl get endpoints -n dev
kubectl get endpoints -n staging
kubectl get endpoints -n prod
kubectl get endpoints -n shared

kubectl get events -n dev --sort-by='.lastTimestamp'

kubectl rollout restart deployment -n kube-system ingress-appgw-deployment


# Clean up resources
az group delete --name $RESOURCE_GROUP --yes --no-wait


