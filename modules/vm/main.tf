resource "azurerm_network_interface" "nic" {
  name                = "nic-${var.prefix}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.pip[0].id : null
  }
}

resource "azurerm_public_ip" "pip" {
  count               = var.create_public_ip ? 1 : 0
  name                = "pip-${var.prefix}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "vm-${var.prefix}-${var.environment}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = var.vm_size

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = var.os_disk_name != "" ? var.os_disk_name : "osdisk-${var.prefix}-${var.environment}"
    caching           = var.os_disk_caching
    create_option     = var.os_disk_create_option
    managed_disk_type = var.os_disk_managed_disk_type
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.ubuntu_sku
    version   = "latest"
  }

  os_profile {
    computer_name  = "vm-${var.prefix}-${var.environment}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.tags
}

# Install Docker on the VM
resource "azurerm_virtual_machine_extension" "docker_extension" {
  name                 = "DockerExtension"
  virtual_machine_id   = azurerm_virtual_machine.vm.id
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
            usermod -aG docker cwadmin
            
            # Enable and start Docker service
            systemctl enable docker
            systemctl start docker
            
            # Verify installation
            docker --version
        EOT
)}"
    }
SETTINGS

tags = {
  environment = "dev"
}
}
