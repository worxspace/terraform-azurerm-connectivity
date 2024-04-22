resource "azurecaf_name" "bastion-name" {
  resource_types = [
    "azurerm_resource_group",
    "azurerm_virtual_network",
    "azurerm_bastion_host",
    "azurerm_public_ip"
  ]
  name     = "${var.project-name}_bastion"
  prefixes = concat(var.resource-prefixes, [local.builtin_azure_backup_geo_codes[var.location]])
  suffixes = concat(var.resource-suffixes, ["001"])
}

resource "azurerm_resource_group" "bastion-resource-group" {
  name     = azurecaf_name.bastion-name.results.azurerm_resource_group
  location = var.location

  tags = var.global-tags
}

resource "azurerm_public_ip" "bastion-ip" {
  name                = azurecaf_name.bastion-name.results.azurerm_public_ip
  location            = var.location
  resource_group_name = azurerm_resource_group.bastion-resource-group.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.global-tags
}

resource "azurerm_virtual_network" "bastion" {
  name                = azurecaf_name.bastion-name.results.azurerm_virtual_network
  location            = var.location
  resource_group_name = azurerm_resource_group.bastion-resource-group.name
  address_space       = [var.bastion-address-space]

  tags = var.global-tags
}

resource "azurerm_subnet" "bastion-subnet" {
  count = var.bastion-address-space == null ? 0 : 1

  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.bastion-resource-group.name
  virtual_network_name = azurerm_virtual_network.bastion.name
  address_prefixes     = [var.bastion-address-space]
}

resource "azurerm_bastion_host" "bastion-basic" {
  count = var.bastion-configuration.sku == "Basic" ? 1 : 0

  name                = azurecaf_name.bastion-name.results.azurerm_bastion_host
  location            = var.location
  resource_group_name = azurerm_resource_group.bastion-resource-group.name

  sku = "Basic"

  copy_paste_enabled = var.bastion-configuration.copy_paste_enabled

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion-subnet[0].id
    public_ip_address_id = azurerm_public_ip.bastion-ip.id
  }

  tags = var.global-tags
}

resource "azurerm_bastion_host" "bastion-std" {
  count = var.bastion-configuration.sku == "Standard" ? 1 : 0

  name                = azurecaf_name.bastion-name.results.azurerm_bastion_host
  location            = var.location
  resource_group_name = azurerm_resource_group.bastion-resource-group.name

  sku = "Standard"

  copy_paste_enabled     = var.bastion-configuration.copy_paste_enabled
  file_copy_enabled      = var.bastion-configuration.file_copy_enabled
  ip_connect_enabled     = var.bastion-configuration.ip_connect_enabled
  shareable_link_enabled = var.bastion-configuration.shareable_link_enabled
  tunneling_enabled      = var.bastion-configuration.tunneling_enabled

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion-subnet[0].id
    public_ip_address_id = azurerm_public_ip.bastion-ip.id
  }

  tags = var.global-tags
}
