data "azurerm_resource_group" "vm" {
    name = "remotedev"
}

// Network
// VNET
resource "azurerm_virtual_network" "vm" {
  name                = "${local.default_suffix}"
  location            = data.azurerm_resource_group.vm.location
  resource_group_name = data.azurerm_resource_group.vm.name
  address_space       = ["192.168.0.0/24"]
}

// Subnet
resource "azurerm_subnet" "default" {
  name                  = "${local.default_suffix}"
  virtual_network_name  = azurerm_virtual_network.vm.name
  resource_group_name   = data.azurerm_resource_group.vm.name
  address_prefixes      = ["192.168.0.0/26"]
}

// NIC
resource "azurerm_network_interface" "default" {
    for_each = toset(local.customers)
    name                = "${each.key}-${local.default_suffix}"
    location            = data.azurerm_resource_group.vm.location
    resource_group_name = data.azurerm_resource_group.vm.name
    ip_configuration {
        name                          = "${each.key}-${local.default_suffix}"
        subnet_id                     = azurerm_subnet.default.id
        private_ip_address_allocation = "Dynamic"
        primary                       = true
    }
}

// Virtual Machine
// VM
resource "azurerm_linux_virtual_machine" "default" {
    for_each = toset(local.customers)
    name                = "${each.key}-${local.default_suffix}"
  location            = data.azurerm_resource_group.vm.location
  resource_group_name = data.azurerm_resource_group.vm.name
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
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

// Auto Shutdown
resource "azurerm_dev_test_global_vm_shutdown_schedule" "default" {
    for_each = toset(local.customers)
    virtual_machine_id = azurerm_linux_virtual_machine.default[each.key].id
    location = data.azurerm_resource_group.vm.location
    enabled = true
    daily_recurrence_time = 1900
    timezone = "Central European Standard Time"
    notification_settings {
      enabled = false
    }
}