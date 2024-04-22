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
  name     = "${var.project-name}_hub"
  prefixes = concat(var.resource-prefixes, [local.builtin_azure_backup_geo_codes[var.location]])
  suffixes = concat(var.resource-suffixes, ["001"])
}

resource "azurecaf_name" "s2s" {
  resource_types = [
    "azurerm_point_to_site_vpn_gateway"
  ]
  name     = "${var.project-name}_hub_s2s"
  prefixes = concat(var.resource-prefixes, [local.builtin_azure_backup_geo_codes[var.location]])
  suffixes = concat(var.resource-suffixes, ["001"])
}

resource "azurecaf_name" "p2s" {
  resource_types = [
    "azurerm_point_to_site_vpn_gateway"
  ]
  name     = "${var.project-name}_hub_p2s"
  prefixes = concat(var.resource-prefixes, [local.builtin_azure_backup_geo_codes[var.location]])
  suffixes = concat(var.resource-suffixes, ["001"])
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

  vpn-s2s-gw-name = azurecaf_name.s2s.results.azurerm_point_to_site_vpn_gateway
  vpn-p2s-gw-name = azurecaf_name.p2s.results.azurerm_point_to_site_vpn_gateway

  user-vpn-config = {
    enabled       = each.value.user-vpn-config.tenant-id != null
    ad-group      = each.value.user-vpn-config.ad-group-name
    address-space = each.value.user-vpn-config.address-space
    dns-servers   = each.value.user-vpn-config.dns-servers
    tenant-id     = each.value.user-vpn-config.tenant-id
  }

  global-tags = var.global-tags
}
