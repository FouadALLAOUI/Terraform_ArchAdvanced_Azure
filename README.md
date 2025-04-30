# Terraform Azure Advanced Architecture

This repository contains Terraform code to deploy an advanced architecture in Azure, including resource groups and CosmosDB.

## Prerequisites

- Docker installed on your system
- Git (to clone this repository)

## Using Docker for Terraform Operations

### Building the Docker Image

1. Navigate to the project directory:
   ```bash
   cd /path/to/Terraform_ArchAdvanced_Azure
   ```

2. Build the Docker image:
   ```bash
   docker build -t terraform-azure-env .
   ```

### Running Terraform Commands in the Container

#### Starting the Container

Start a container with the current directory mounted:

```bash
docker run -it --rm \
  -v $(pwd):/terraform \
  -w /terraform \
  terraform-azure-env
```

#### Authenticating with Azure

Once inside the container, authenticate with Azure:

```bash
az login
```

A browser window will open for you to complete the authentication process.

Alternatively, use a service principal:

```bash
az login --service-principal \
  --username APP_ID \
  --password PASSWORD \
  --tenant TENANT_ID
```

#### Terraform Operations

Initialize the Terraform configuration:

```bash
terraform init
```

Preview the changes:

```bash
terraform plan -out=tfplan
```

Apply the changes:

```bash
terraform apply tfplan
```

Destroy the resources when no longer needed:

```bash
terraform destroy
```

### Useful Docker Commands

* Check running containers:
  ```bash
  docker ps
  ```

* Execute commands in a running container:
  ```bash
  docker exec -it CONTAINER_ID bash
  ```

* Stop a running container:
  ```bash
  docker stop CONTAINER_ID
  ```

## Project Structure

- `main.tf` - Main Terraform configuration file
- `variables.tf` - Variable definitions
- `terraform.tfvars` - Variable values
- `providers.tf` - Provider configuration
- `modules/` - Reusable Terraform modules

## Notes

- The mounted volume ensures that Terraform state files are preserved on your local machine.
- Running with `--rm` flag ensures the container is removed after you exit it.
