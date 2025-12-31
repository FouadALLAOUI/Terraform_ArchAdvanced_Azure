#!/bin/bash

echo "hello script of linux"

# Set variables
RESOURCE_GROUP="rg-aks-agic-lab-v2"
LOCATION="eastus"
AKS_NAME="aks-agic-cluster-v2"
APPGW_NAME="appgw-aks-ingress-v2"

# Application Gateway VNet and Subnet
APPGW_VNET_NAME="vnet-appgw"
APPGW_VNET_PREFIX="10.0.0.0/16"
APPGW_SUBNET_NAME="subnet-appgw"
APPGW_SUBNET_PREFIX="10.0.1.0/24"

# AKS VNet and Subnet
AKS_VNET_NAME="vnet-aks"
AKS_VNET_PREFIX="10.1.0.0/16"
AKS_SUBNET_NAME="subnet-aks"
AKS_SUBNET_PREFIX="10.1.1.0/24"

# Service CIDR (for Kubernetes internal services)
SERVICE_CIDR="10.2.0.0/16"
DNS_SERVICE_IP="10.2.0.10"

# Public IP
PUBLIC_IP_NAME="pip-appgw-v2"

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

echo "✓ Resource group created: $RESOURCE_GROUP"

# Create Application Gateway VNet
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $APPGW_VNET_NAME \
  --address-prefix $APPGW_VNET_PREFIX \
  --location $LOCATION

echo "✓ Application Gateway VNet created: $APPGW_VNET_NAME ($APPGW_VNET_PREFIX)"

# Create Application Gateway subnet
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $APPGW_VNET_NAME \
  --name $APPGW_SUBNET_NAME \
  --address-prefix $APPGW_SUBNET_PREFIX

echo "✓ Application Gateway subnet created: $APPGW_SUBNET_NAME ($APPGW_SUBNET_PREFIX)"


# Create AKS VNet
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_VNET_NAME \
  --address-prefix $AKS_VNET_PREFIX \
  --location $LOCATION

echo "✓ AKS VNet created: $AKS_VNET_NAME ($AKS_VNET_PREFIX)"

# Create AKS subnet
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $AKS_VNET_NAME \
  --name $AKS_SUBNET_NAME \
  --address-prefix $AKS_SUBNET_PREFIX

echo "✓ AKS subnet created: $AKS_SUBNET_NAME ($AKS_SUBNET_PREFIX)"

echo "=== Network Address Verification ==="
echo "Application Gateway VNet: $APPGW_VNET_PREFIX"
echo "AKS VNet: $AKS_VNET_PREFIX"
echo "Service CIDR: $SERVICE_CIDR"
echo "DNS Service IP: $DNS_SERVICE_IP"
echo ""
echo "✓ All address spaces are non-overlapping"

# Get VNet IDs
APPGW_VNET_ID=$(az network vnet show \
  --resource-group $RESOURCE_GROUP \
  --name $APPGW_VNET_NAME \
  --query id -o tsv)

AKS_VNET_ID=$(az network vnet show \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_VNET_NAME \
  --query id -o tsv)

# Create peering from Application Gateway VNet to AKS VNet
az network vnet peering create \
  --name appgw-to-aks-peering \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $APPGW_VNET_NAME \
  --remote-vnet $AKS_VNET_ID \
  --allow-vnet-access \
  --allow-forwarded-traffic

echo "✓ Peering created: Application Gateway VNet → AKS VNet"

# Create peering from AKS VNet to Application Gateway VNet
az network vnet peering create \
  --name aks-to-appgw-peering \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $AKS_VNET_NAME \
  --remote-vnet $APPGW_VNET_ID \
  --allow-vnet-access \
  --allow-forwarded-traffic

echo "✓ Peering created: AKS VNet → Application Gateway VNet"

# Check peering status
echo "=== VNet Peering Status ==="
az network vnet peering list \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $APPGW_VNET_NAME \
  --query "[].{Name:name, PeeringState:peeringState, RemoteVnet:remoteVirtualNetwork.id}" \
  --output table

az network vnet peering list \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $AKS_VNET_NAME \
  --query "[].{Name:name, PeeringState:peeringState, RemoteVnet:remoteVirtualNetwork.id}" \
  --output table

echo ""
echo "✓ Both peerings should show 'Connected' status"

# Create Public IP for Application Gateway
az network public-ip create \
  --resource-group $RESOURCE_GROUP \
  --name $PUBLIC_IP_NAME \
  --allocation-method Static \
  --sku Standard \
  --location $LOCATION

echo "✓ Public IP created: $PUBLIC_IP_NAME"


az network application-gateway create \
  --name $APPGW_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_v2 \
  --capacity 2 \
  --vnet-name $APPGW_VNET_NAME \
  --subnet $APPGW_SUBNET_NAME \
  --public-ip-address $PUBLIC_IP_NAME \
  --priority 100

echo "✓ Application Gateway created: $APPGW_NAME"


# Create AKS cluster with AGIC addon
# Get AKS subnet ID
AKS_SUBNET_ID=$(az network vnet subnet show \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $AKS_VNET_NAME \
  --name $AKS_SUBNET_NAME \
  --query id -o tsv)

# Get Application Gateway ID
APPGW_ID=$(az network application-gateway show \
  --name $APPGW_NAME \
  --resource-group $RESOURCE_GROUP \
  --query id -o tsv)

echo "Creating AKS cluster... (this will take 5-10 minutes)"

# Create AKS cluster with AGIC addon
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --location $LOCATION \
  --network-plugin azure \
  --vnet-subnet-id $AKS_SUBNET_ID \
  --service-cidr $SERVICE_CIDR \
  --dns-service-ip $DNS_SERVICE_IP \
  --enable-managed-identity \
  --node-count 2 \
  --node-vm-size Standard_DS2_v2 \
  --enable-addons ingress-appgw \
  --appgw-id $APPGW_ID \
  --generate-ssh-keys

echo "✓ AKS cluster created: $AKS_NAME"


# Get the AKS node resource group
AKS_NODE_RG=$(az aks show \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --query nodeResourceGroup -o tsv)

echo "AKS Node Resource Group: $AKS_NODE_RG"

# Get the route table created by AKS
ROUTE_TABLE_NAME=$(az network route-table list \
  --resource-group $AKS_NODE_RG \
  --query "[0].name" -o tsv)

if [ -z "$ROUTE_TABLE_NAME" ]; then
  echo "⚠ No route table found. This is normal with Azure CNI."
  echo "Route table association is only needed with Kubenet."
else
  echo "Route table found: $ROUTE_TABLE_NAME"
  
  # Get route table ID
  ROUTE_TABLE_ID=$(az network route-table show \
    --resource-group $AKS_NODE_RG \
    --name $ROUTE_TABLE_NAME \
    --query id -o tsv)
  
  # Associate route table with Application Gateway subnet
  az network vnet subnet update \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $APPGW_VNET_NAME \
    --name $APPGW_SUBNET_NAME \
    --route-table $ROUTE_TABLE_ID
  
  echo "✓ Route table associated with Application Gateway subnet"
fi

az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --overwrite-existing

echo "✓ Credentials configured"

# Verify connection
kubectl get nodes

# Verify AGIC is running
kubectl get pods -n kube-system -l app=ingress-appgw

echo "✓ AGIC pod should be running"

echo "All done! Your AKS cluster with Application Gateway Ingress Controller is set up."

# Create namespaces
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace prod
kubectl create namespace shared

echo "✓ Namespaces created: dev, staging, prod, shared"

# Deploy sample applications
chmod +x deploy-apps-v2.sh
./deploy-apps-v2.sh

# Check all pods
echo "=== All Pods ==="
kubectl get pods --all-namespaces -o wide

# Check pods per namespace
echo ""
echo "=== Dev Namespace ==="
kubectl get pods,svc -n dev

echo ""
echo "=== Staging Namespace ==="
kubectl get pods,svc -n staging

echo ""
echo "=== Prod Namespace ==="
kubectl get pods,svc -n prod

echo ""
echo "=== Shared Namespace ==="
kubectl get pods,svc -n shared

# Create Ingress resources
chmod +x create-ingress-v2.sh
./create-ingress-v2.sh

# Watch ingress resources (wait for ADDRESS to appear)
echo "Watching for Ingress ADDRESS assignment..."
echo "This may take 2-5 minutes..."
echo ""

kubectl get ingress --all-namespaces -w

# Get the public IP
APPGW_PUBLIC_IP=$(az network public-ip show \
  --resource-group $RESOURCE_GROUP \
  --name $PUBLIC_IP_NAME \
  --query ipAddress -o tsv)

echo "================================="
echo "Application Gateway Public IP: $APPGW_PUBLIC_IP"
echo "================================="

echo "You can now access the applications using the following URLs:"

# Test dev namespace apps
echo "Testing Dev namespace..."
curl http://$APPGW_PUBLIC_IP/dev/app1/
curl http://$APPGW_PUBLIC_IP/dev/app2/
curl http://$APPGW_PUBLIC_IP/dev/app3/

echo ""
echo "Testing Staging namespace..."
curl http://$APPGW_PUBLIC_IP/staging/app1/
curl http://$APPGW_PUBLIC_IP/staging/app2/
curl http://$APPGW_PUBLIC_IP/staging/app3/

echo ""
echo "Testing Prod namespace..."
curl http://$APPGW_PUBLIC_IP/prod/app1/
curl http://$APPGW_PUBLIC_IP/prod/app2/
curl http://$APPGW_PUBLIC_IP/prod/app3/

echo ""
echo "Testing Shared namespace..."
curl http://$APPGW_PUBLIC_IP/shared/app1/
curl http://$APPGW_PUBLIC_IP/shared/app2/
curl http://$APPGW_PUBLIC_IP/shared/app3/


# Show VNet peering status
echo "=== VNet Peering Status ==="
az network vnet peering show \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $APPGW_VNET_NAME \
  --name appgw-to-aks-peering \
  --query "{Name:name, State:peeringState, AllowForwarded:allowForwardedTraffic}" \
  --output table

az network vnet peering show \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $AKS_VNET_NAME \
  --name aks-to-appgw-peering \
  --query "{Name:name, State:peeringState, AllowForwarded:allowForwardedTraffic}" \
  --output table

# Show Application Gateway backend health
echo ""
echo "=== Application Gateway Backend Health ==="
az network application-gateway show-backend-health \
  --resource-group $RESOURCE_GROUP \
  --name $APPGW_NAME \
  --output table

# View backend pools
echo "=== Backend Pools ==="
az network application-gateway address-pool list \
  --resource-group $RESOURCE_GROUP \
  --gateway-name $APPGW_NAME \
  --output table

# View HTTP settings
echo ""
echo "=== HTTP Settings ==="
az network application-gateway http-settings list \
  --resource-group $RESOURCE_GROUP \
  --gateway-name $APPGW_NAME \
  --output table

# View routing rules
echo ""
echo "=== Routing Rules ==="
az network application-gateway rule list \
  --resource-group $RESOURCE_GROUP \
  --gateway-name $APPGW_NAME \
  --output table

az network vnet peering list \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $APPGW_VNET_NAME \
  --output table

az network vnet peering list \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $AKS_VNET_NAME \
  --output table

az network vnet subnet show \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $APPGW_VNET_NAME \
  --name $APPGW_SUBNET_NAME \
  --query routeTable


AGIC_POD=$(kubectl get pods -n kube-system -l app=ingress-appgw -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n kube-system $AGIC_POD --tail=50


echo "App Gateway VNet: $APPGW_VNET_PREFIX"
echo "AKS VNet: $AKS_VNET_PREFIX"
echo "Service CIDR: $SERVICE_CIDR"

kubectl describe ingress -n dev
kubectl get events -n dev --sort-by='.lastTimestamp'

kubectl rollout restart deployment -n kube-system -l app=ingress-appgw

kubectl run test-pod --image=busybox --rm -it --restart=Never -- /bin/sh


# Delete the resource group (deletes everything)
az group delete --name $RESOURCE_GROUP --yes --no-wait

echo "✓ Cleanup initiated. Resources will be deleted in the background."






