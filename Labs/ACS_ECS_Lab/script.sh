#!/bin/bash

echo "hello script of linux"

echo "This is ACS ECS Lab script."


# Set variables
RESOURCE_GROUP="rg-acs-email-lab"
LOCATION="eastus"

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# List resource groups
az group list --output table

# Show specific resource group
az group show --name $RESOURCE_GROUP

# Set variables
ACS_NAME="acs-email-service-lab"
DATA_LOCATION="UnitedStates"

# Create Communication Services resource
az communication create \
  --name $ACS_NAME \
  --resource-group $RESOURCE_GROUP \
  --data-location $DATA_LOCATION

# List Communication Services
az communication list --output table

# Show specific Communication Services
az communication show --name $ACS_NAME --resource-group $RESOURCE_GROUP


# Get connection string
az communication list-key \
  --name $ACS_NAME \
  --resource-group $RESOURCE_GROUP

# Store in variable for later use
CONNECTION_STRING=$(az communication list-key \
  --name $ACS_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "primaryConnectionString" \
  --output tsv)

echo "Connection String: $CONNECTION_STRING"




