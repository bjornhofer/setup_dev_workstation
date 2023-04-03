resource "azurerm_resource_group" "default" {
    name = "remotedev2"
    location = "westeurope"
}

// Network
// VNET
resource "azurerm_virtual_network" "default" {
  name                = "vnet-${local.default_suffix}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["192.168.0.0/24"]
}

// Subnet
resource "azurerm_subnet" "default" {
  name                  = "sn-${local.default_suffix}"
  virtual_network_name  = azurerm_virtual_network.default.name
  resource_group_name   = azurerm_resource_group.default.name
  address_prefixes      = ["192.168.0.0/26"]
}

// NIC
resource "azurerm_network_interface" "default" {
    for_each = toset(local.customers)
    name                = "${each.key}-${local.default_suffix}"
    location            = azurerm_resource_group.default.location
    resource_group_name = azurerm_resource_group.default.name
    ip_configuration {
        name                          = "${each.key}-${local.default_suffix}"
        subnet_id                     = azurerm_subnet.default.id
        private_ip_address_allocation = "Dynamic"
        primary                       = true
        //public_ip_address_id          = azurerm_public_ip.default[each.key].id
    }
}

// Virtual Machine
// VM
resource "azurerm_linux_virtual_machine" "default" {
    for_each = toset(local.customers)
    name                = "${each.key}-${local.default_suffix}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  size                = local.settings.vmsize
  admin_username      = "azuser"
  network_interface_ids = [
    azurerm_network_interface.default[each.key].id
  ]

  admin_ssh_key {
    username   = "azuser"
    public_key = local.settings.ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name = "${each.key}-${local.default_suffix}"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

// Auto Shutdown
resource "azurerm_dev_test_global_vm_shutdown_schedule" "default" {
    for_each = toset(local.customers)
    virtual_machine_id = azurerm_linux_virtual_machine.default[each.key].id
    location = azurerm_resource_group.default.location
    enabled = true
    daily_recurrence_time = 1900
    timezone = "Central European Standard Time"
    notification_settings {
      enabled = false
    }
}