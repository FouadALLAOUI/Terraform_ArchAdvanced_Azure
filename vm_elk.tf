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
            apt-get upgrade -y
            
            # Install Java (prerequisite for ELK stack)
            apt-get install -y openjdk-17-jdk
            
            # Verify Java installation
            java -version
            
            # Increase virtual memory for Elasticsearch
            sysctl -w vm.max_map_count=262144
            echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
            
            # Install supporting utilities
            apt-get install -y apt-transport-https curl wget gnupg2 software-properties-common
            
            # Add Elasticsearch GPG key and repository
            wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
            echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list
            
            # Update apt
            apt-get update
            
            # Install Elasticsearch
            apt-get install -y elasticsearch
            
            # Configure Elasticsearch
            cat > /etc/elasticsearch/elasticsearch.yml << 'EOF'
            cluster.name: elk-cluster
            node.name: elk-node-1
            path.data: /var/lib/elasticsearch
            path.logs: /var/log/elasticsearch
            network.host: 0.0.0.0
            http.port: 9200
            discovery.type: single-node
            xpack.security.enabled: false
            EOF
            
            # Set JVM heap size for Elasticsearch
            cat > /etc/elasticsearch/jvm.options.d/heap.options << 'EOF'
            -Xms512m
            -Xmx512m
            EOF
            
            # Enable and start Elasticsearch service
            systemctl daemon-reload
            systemctl enable elasticsearch.service
            systemctl start elasticsearch.service
            
            # Install Logstash
            apt-get install -y logstash
            
            # Configure Logstash
            cat > /etc/logstash/logstash.yml << 'EOF'
            http.host: "0.0.0.0"
            path.config: /etc/logstash/conf.d
            EOF
            
            # Set JVM heap size for Logstash
            cat > /etc/logstash/jvm.options.d/heap.options << 'EOF'
            -Xms256m
            -Xmx256m
            EOF
            
            # Create basic Logstash pipeline configuration
            cat > /etc/logstash/conf.d/logstash.conf << 'EOF'
            input {
              beats {
                port => 5044
              }
              tcp {
                port => 5000
              }
            }
            
            filter {
              # Add your filters here
            }
            
            output {
              elasticsearch {
                hosts => ["localhost:9200"]
                index => "%%{[@metadata][beat]}-%%{[@metadata][version]}-%%{+YYYY.MM.dd}"
                # Use the line below if no beats metadata is available
                # index => "logstash-%%{+YYYY.MM.dd}"
              }
            }
            EOF
            
            # Enable and start Logstash service
            systemctl enable logstash.service
            systemctl start logstash.service
            
            # Install Kibana
            apt-get install -y kibana
            
            # Configure Kibana
            cat > /etc/kibana/kibana.yml << 'EOF'
            server.port: 5601
            server.host: "0.0.0.0"
            elasticsearch.hosts: ["http://localhost:9200"]
            EOF
            
            # Enable and start Kibana service
            systemctl enable kibana.service
            systemctl start kibana.service
            
            # Install Filebeat (optional)
            apt-get install -y filebeat
            
            # Configure Filebeat to collect system logs
            cat > /etc/filebeat/filebeat.yml << 'EOF'
            filebeat.inputs:
            - type: log
              enabled: true
              paths:
                - /var/log/*.log
                - /var/log/syslog
                
            filebeat.config.modules:
              path: $${path.config}/modules.d/*.yml
              reload.enabled: false
              
            setup.template.settings:
              index.number_of_shards: 1
              
            output.elasticsearch:
              hosts: ["localhost:9200"]
              
            setup.kibana:
              host: "localhost:5601"
            EOF
            
            # Enable and start Filebeat service
            systemctl enable filebeat.service
            systemctl start filebeat.service
            
            # Setup firewall rules
            apt-get install -y ufw
            ufw allow ssh
            ufw allow 5601/tcp
            ufw allow 9200/tcp
            ufw allow 5044/tcp
            ufw allow 5000/tcp
            echo "y" | ufw enable
            
            # Create a welcome message with access instructions
            echo "ELK Stack installation complete. Access Kibana at http://$(curl -s ifconfig.me):5601" > /etc/motd
            
            # Check services status
            systemctl status elasticsearch.service --no-pager
            systemctl status logstash.service --no-pager
            systemctl status kibana.service --no-pager
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