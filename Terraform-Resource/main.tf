provider "azurerm" {
  features {}
  subscription_id = "975f2f0a-fb15-4ffc-8a94-e3e778f2ab22"  
}

resource "azurerm_resource_group" "rg" {
  name     = "my-resource-group"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "my-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "vm-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "public-ip-config"
    subnet_id                     = azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowDocker"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2375-2376"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "my-windows-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B2ms"
  admin_username        = "adminuser"
  admin_password        = "P@ssw0rd123!" # Change this to a secure password
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-smalldisk"
    version   = "latest"
  }

  custom_data = base64encode(<<EOF
  # Create PowerShell Script File
  $scriptPath = "C:\\install-docker.ps1"
  $taskName = "InstallDocker"

  # Write the script to install Windows Containers and Docker
  @"
  # Enable Script Execution
  Set-ExecutionPolicy Unrestricted -Scope Process -Force

  # Install Windows Containers
  Install-WindowsFeature -Name Containers -IncludeAllSubFeature -Restart

  # Wait for Reboot and Resume
  while ((Get-Service -Name wuauserv).Status -ne "Running") { Start-Sleep -Seconds 30 }

  # Install Docker
  Invoke-WebRequest -Uri "https://download.docker.com/win/static/stable/x86_64/docker-20.10.7.zip" -OutFile "docker.zip"
  Expand-Archive -Path "docker.zip" -DestinationPath "C:\\docker"
  [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\\docker", [System.EnvironmentVariableTarget]::Machine)

  # Install AWS CLI
  Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "AWSCLIV2.msi"
  Start-Process msiexec.exe -ArgumentList "/i AWSCLIV2.msi /quiet" -Wait

  # Authenticate Docker with AWS ECR
  Write-Output "Authenticating Docker with AWS ECR..."
  $ECR_LOGIN = aws ecr get-login-password --region us-east-1
  docker login --username AWS --password-stdin 970547375353.dkr.ecr.us-east-1.amazonaws.com

  # Pull and Run API and UI Containers
  docker pull 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-api-image-repo:latest
  docker run -d --name mcrp-api-container -p 5000:5000 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-api-image-repo:latest

  docker pull 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-ui-image-repo:latest
  docker run -d --name mcrp-ui-container -p 80:80 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-ui-image-repo:latest

  Write-Output "Docker containers for API and UI are now running!"
  "@ | Out-File -FilePath $scriptPath -Encoding ascii

  # Schedule Task to Run at Startup
  $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $scriptPath"
  $trigger = New-ScheduledTaskTrigger -AtStartup
  $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\\SYSTEM" -LogonType ServiceAccount
  $task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Description "Install Docker and Containers on Startup"

  Register-ScheduledTask -TaskName $taskName -InputObject $task -Force
  EOF
  )
}

