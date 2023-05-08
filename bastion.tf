resource "azurecaf_name" "bastion-name" {
  resource_types = [
    "azurerm_resource_group",
    "azurerm_bastion_host",
    "azurerm_public_ip"
  ]
  name     = "bastion"
  prefixes = [var.tenant-short-name]
}

resource "azurerm_resource_group" "bastion-resource-group" {
  name     = azurecaf_name.bastion-name.results.azurerm_resource_group
  location = var.location
}

resource "azurerm_public_ip" "bastion-ip" {
  name                = azurecaf_name.bastion-name.results.azurerm_public_ip
  location            = var.location
  resource_group_name = azurerm_resource_group.bastion-resource-group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = azurecaf_name.bastion-name.results.azurerm_bastion_host
  location            = var.location
  resource_group_name = azurerm_resource_group.bastion-resource-group.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion-subnet[0].id
    public_ip_address_id = azurerm_public_ip.bastion-ip.id
  }
}
