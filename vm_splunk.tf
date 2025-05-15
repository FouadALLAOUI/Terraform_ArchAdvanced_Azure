#Standard_B2s = 2 CPU, 4GB RAM
module "vm_splunk" {
  source              = "./modules/vm"
  resource_group_name = azurerm_resource_group.rg_dev.name
  location            = azurerm_resource_group.rg_dev.location
  vm_size             = "Standard_B2s"
  subnet_id           = module.network.back_subnet_id
  create_public_ip    = true
  prefix              = "splunk-vm"
  environment         = "dev"
  admin_username      = "cwadmin"
  admin_password      = "ConnectedW0rkers!2025"
  tags = {
    environment = "dev"
  }
}

# Install Docker & Splunk on the VM
resource "azurerm_virtual_machine_extension" "docker_extension_splunk" {
  name                 = "DockerExtension"
  virtual_machine_id   = module.vm_splunk.vm_id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
        "script": "${base64encode(<<-EOT
            #!/bin/bash
            # Update package information
            apt-get update -y
            
            # Install required packages
            apt-get install -y \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg \
                lsb-release
            
            # Add Docker's official GPG key
            mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            
            # Add Docker repository
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
              $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            # Install Docker Engine
            apt-get update -y
            apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            
            # Add admin user to the docker group
            usermod -aG docker ${var.admin_username}
            
            # Enable and start Docker service
            systemctl enable docker
            systemctl start docker
            
            # Create Splunk directories
            mkdir -p /tmp/splunk_home
            sudo chown -R 1000:1000 /tmp/splunk_home
            
            # Run Jenkins container
            docker run -d -p 8000:8000 -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_PASSWORD=${var.admin_password}" --name splunk splunk/splunk:latest

        EOT
)}"
    }
SETTINGS

  tags = var.tags
}

# Local Exec to store the Public IP Address of the VM
resource "local_file" "splunk_public_ip" {
  content = module.vm_splunk.public_ip_address
  filename = "splunk_public_ip.txt"
}

