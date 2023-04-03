data "azurerm_resource_group" "default" {
    name = var.management
}

data "azurerm_virtual_network" "vmvnet" {
    name = "vnet-${local.default_suffix}"
    resource_group_name = "remotedev2"
    depends_on = [
      azurerm_resource_group.default
    ]
}

# // VNET
resource "azurerm_virtual_network" "management" {
    name                = "vnet-${var.management}"
    location            = data.azurerm_resource_group.default.location
    resource_group_name = data.azurerm_resource_group.default.name
    address_space       = ["10.0.10.0/24"]
}

# // Subnet
resource "azurerm_subnet" "management" {
    name                  = "sn-${var.management}"
    virtual_network_name  = azurerm_virtual_network.management.name
    resource_group_name   = data.azurerm_resource_group.default.name
    address_prefixes      = ["10.0.10.0/24"]
}

resource "azurerm_subnet" "AzureBastionSubnet" {
    name = "AzureBastionSubnet"
    resource_group_name = data.azurerm_resource_group.default.name
    virtual_network_name = azurerm_virtual_network.management.name
    address_prefixes = ["10.0.11.0/24"]
}

resource "azurerm_virtual_network_peering" "mgmt2vm" {
    name = "mgmt2vm"
    resource_group_name = data.azurerm_resource_group.default.name
    virtual_network_name = azurerm_virtual_network.management.name
    remote_virtual_network_id = data.azurerm_virtual_network.vmvnet.id
}

resource "azurerm_virtual_network_peering" "vm2mgmt" {
    name = "vm2mgmt"
    resource_group_name = data.azurerm_resource_group.default.name
    virtual_network_name = data.azurerm_virtual_network.vmvnet.name
    remote_virtual_network_id = azurerm_virtual_network.management.id
}

// Bastion Host
// Public IP
resource "azurerm_public_ip" "bastion" {
  name                = "bastion"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bastion"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
  sku = "Standard"
  tunneling_enabled = true
  file_copy_enabled = true


}