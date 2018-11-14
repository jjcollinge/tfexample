provider "azurerm" {}

resource "azurerm_resource_group" "resource_group" {
    name     = "${var.resource_group_name}"
    location = "${var.resource_group_location}"

    tags {
        environment = "Deploy to Azure"
    }
}

resource "azurerm_virtual_network" "vnet" {
    name                = "${var.vnet_name}"
    address_space       = ["10.0.0.0/16"]
    location            = "${azurerm_resource_group.resource_group.location}"
    resource_group_name = "${azurerm_resource_group.resource_group.name}"

    tags {
        environment = "Deploy to Azure"
    }
}

resource "azurerm_subnet" "subnet" {
    name                 = "${var.subnet_name}"
    resource_group_name  = "${azurerm_resource_group.resource_group.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "public_ip" {
    name                         = "${var.public_ip_name}"
    location                     = "${azurerm_resource_group.resource_group.location}"
    resource_group_name          = "${azurerm_resource_group.resource_group.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Deploy to Azure"
    }
}

resource "azurerm_network_security_group" "network_security_group" {
    name                = "${var.network_security_group_name}"
    location            = "${azurerm_resource_group.resource_group.location}"
    resource_group_name = "${azurerm_resource_group.resource_group.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Deploy to Azure"
    }
}

resource "azurerm_network_interface" "nic" {
    name                      = "${var.network_interface_name}"
    location                  = "${azurerm_resource_group.resource_group.location}"
    resource_group_name       = "${azurerm_resource_group.resource_group.name}"
    network_security_group_id = "${azurerm_network_security_group.network_security_group.id}"

    ip_configuration {
        name                          = "${var.network_interface_name}-ipconfig"
        subnet_id                     = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.public_ip.id}"
    }

    tags {
        environment = "Deploy to Azure"
    }
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.resource_group.name}"
    }

    byte_length = 8
}

resource "azurerm_storage_account" "storage_account" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.resource_group.name}"
    location                    = "${azurerm_resource_group.resource_group.location}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags {
        environment = "Deploy to Azure"
    }
}

resource "azurerm_virtual_machine" "virtual_machine" {
    name                  = "${var.virtual_machine_name}"
    location              = "${azurerm_resource_group.resource_group.location}"
    resource_group_name   = "${azurerm_resource_group.resource_group.name}"
    network_interface_ids = ["${azurerm_network_interface.nic.id}"]
    vm_size               = "${var.virtual_machine_size}"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "${var.virtual_machine_name}"
        admin_username = "${var.admin_user}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/${var.admin_user}/.ssh/authorized_keys"
            key_data = "${file("~/.ssh/id_rsa.pub")}"
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.storage_account.primary_blob_endpoint}"
    }

    tags {
        environment = "Deploy to Azure"
    }
}