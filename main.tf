/**
 * # tfm-azure-connectivity
 *
 * Creates connectivity hub in azure in a standardised way using the latest recommendations.
 *
 * We use azurecaf_name to generate a unique name for the user assigned identity.
 * so make sure to provide the project-name, prefixes, suffixes as necessary
 */

resource "azurecaf_name" "hub-name" {
  resource_types = [
    "azurerm_resource_group",
    "azurerm_virtual_network",
    "azurerm_virtual_wan"
  ]
  name     = "${var.project-name}-hub"
  prefixes = var.resource-prefixes
  suffixes = var.resource-suffixes
}

resource "azurerm_resource_group" "connectivity-resource-group" {
  name     = azurecaf_name.hub-name.results.azurerm_resource_group
  location = var.location

  tags = var.global-tags
}

resource "azurerm_virtual_wan" "vwan" {
  name                = azurecaf_name.hub-name.results.azurerm_virtual_wan
  resource_group_name = azurerm_resource_group.connectivity-resource-group.name
  location            = var.location

  office365_local_breakout_category = "OptimizeAndAllow"


  tags = var.global-tags
}

module "vhub" {
  for_each = { for hub in var.hubs : hub.name => hub }

  source = "./virtualhub"

  resource-group-name = azurerm_resource_group.connectivity-resource-group.name
  hub-name            = "${azurerm_virtual_wan.vwan.name}-${each.key}"
  location            = var.location
  address-space       = each.value.address-space
  virtual-wan-id      = azurerm_virtual_wan.vwan.id

  vnets     = concat(each.value.vnets, [{ name = "bastion", id = azurerm_virtual_network.bastion.id }])
  vpn-sites = each.value.vpn-sites

  global-tags = var.global-tags
}
