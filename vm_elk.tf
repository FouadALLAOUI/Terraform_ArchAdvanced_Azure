module "vm_elk" {
  source              = "./modules/vm"
  resource_group_name = azurerm_resource_group.rg_dev.name
  location            = azurerm_resource_group.rg_dev.location
  vm_size             = "Standard_B1s"
  subnet_id           = module.network.back_subnet_id
  create_public_ip    = true
  prefix              = "elk-vm"
  environment         = "dev"
  admin_username      = "cwadmin"
  admin_password      = "ConnectedW0rkers!2025"
  tags = {
    environment = "dev"
  }
}

# Install Docker & ELK on the VM
resource "azurerm_virtual_machine_extension" "docker_extension_elk" {
  name                 = "DockerExtension"
  virtual_machine_id   = module.vm_elk.vm_id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
        "script": "${base64encode(<<-EOT
            #!/bin/bash
            # Update package information
            apt-get update -y
            

        EOT
)}"
    }
SETTINGS

  tags = var.tags
}

# Local Exec to store the Public IP Address of the VM
resource "local_file" "elk_public_ip" {
  content = module.vm_elk.public_ip_address
  filename = "elk_public_ip.txt"
}
