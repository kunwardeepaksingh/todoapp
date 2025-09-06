resource "azurerm_resource_group" "frontend" {
name =          var.rg_name
location =      var.rg_location
}

resource "azurerm_virtual_network" "fevnet" {
name =                     var.vnet_name 
location =                 azurerm_resource_group.frontend.location
resource_group_name =      azurerm_resource_group.frontend.name
address_space =            ["10.0.0.0/16"]
}

resource "azurerm_subnet" "fesubnet" {
name =                      var.subnet_name
resource_group_name =      azurerm_resource_group.frontend.name
virtual_network_name =      azurerm_virtual_network.fevnet.name
address_prefixes =          ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "fepubip" {
    name = var.public_ip_name
    resource_group_name = azurerm_resource_group.frontend.name
    location = azurerm_resource_group.frontend.location
    allocation_method = "Static"
}

resource "azurerm_network_interface" "fenic"{
    name                = var.nic_name
    resource_group_name = azurerm_resource_group.frontend.name
    location            = azurerm_resource_group.frontend.location

    ip_configuration {
        name                  = var.ip_name
        subnet_id             = azurerm_subnet.fesubnet.id
        public_ip_address_id  = azurerm_public_ip.fepubip.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_linux_virtual_machine" "fevm" {
    name = var.vm_name
    resource_group_name = azurerm_resource_group.frontend.name
    location = azurerm_resource_group.frontend.location
    size = "Standard_B4ms"
    admin_username = "admin2025"
    admin_password = var.fe_pass
    network_interface_ids = [azurerm_network_interface.fenic.id]
    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
  output "public_ip_address" {
  description = "The public IP address of the VM"
  value       = azurerm_public_ip.fepubip.ip_address
}
