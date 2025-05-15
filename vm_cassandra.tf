#Standard_B2s = 2 CPU, 4GB RAM
module "vm_cassandra" {
  source              = "./modules/vm"
  resource_group_name = azurerm_resource_group.rg_dev.name
  location            = azurerm_resource_group.rg_dev.location
  vm_size             = "Standard_B2s"
  subnet_id           = module.network.back_subnet_id
  create_public_ip    = true
  prefix              = "cassandra-vm"
  environment         = "dev"
  admin_username      = "cwadmin"
  admin_password      = "ConnectedW0rkers!2025"
  tags = {
    environment = "dev"
  }
}

# Install Docker & Cassandra on the VM
resource "azurerm_virtual_machine_extension" "installation_extension_cassandra" {
  name                 = "InstallationExtension"
  virtual_machine_id   = module.vm_cassandra.vm_id
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

            apt install openjdk-11-jdk -y
            apt install openjdk-11-jre -y
            java -version
            javac -version

            # Install Cassandra
            wget -qO- https://downloads.apache.org/cassandra/KEYS | sudo apt-key add -
            echo "deb https://debian.cassandra.apache.org 41x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
            apt-get update -y
            apt-get install -y cassandra

            nodetool status

            sudo systemctl status cassandra
            sudo systemctl start cassandra
            sudo systemctl enable cassandra
            sudo systemctl status cassandra

        EOT
)}"
    }
SETTINGS

  tags = var.tags
}

# Local Exec to store the Public IP Address of the VM
resource "local_file" "cassandra_public_ip" {
  content = module.vm_cassandra.public_ip_address
  filename = "cassandra_public_ip.txt"
}

