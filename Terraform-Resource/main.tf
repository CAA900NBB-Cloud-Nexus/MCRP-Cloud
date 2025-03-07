provider "azurerm" {
  features {}
  use_msi         = false
  subscription_id = "975f2f0a-fb15-4ffc-8a94-e3e778f2ab22"
}

variable "resource_group_name" {
  default = "myResourceGroup"
}

variable "location" {
  default = "East US"
}

variable "vm_name" {
  default = "WinDockerVM"  
}

variable "admin_user" {
  default = "azureadmin"
}

variable "admin_password" {
  default = "Shridhar1234"  
}

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_account_id" {
  default = "970547375353"  
}

variable "ecr_api_repo" {
  default = "mcrp-api-image-repo"
}

variable "ecr_ui_repo" {
  default = "mcrp-ui-image-repo"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "myVNet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "myNIC"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  ip_configuration {
    name                          = "myNicConfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "vm" {
  name                = "myPublicIP"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  }

resource "azurerm_network_security_rule" "winrm" {
  name                        = "Allow-WinRM"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5985"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}


resource "azurerm_windows_virtual_machine" "vm" {
  name                  = var.vm_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_D2s_v3"
  admin_username        = var.admin_user
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2019-Datacenter"
  version   = "latest"
  }

  provisioner "file" {
    source      = "install-docker.ps1"  # Path to your local file
    destination = "C:\\install-docker.ps1"

    connection {
      type     = "winrm"
      user     = var.admin_user
      password = var.admin_password
      host     = azurerm_public_ip.vm.ip_address
      insecure = true
    }
  }
}


