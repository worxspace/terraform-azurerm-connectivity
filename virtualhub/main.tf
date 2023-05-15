resource "azurerm_virtual_hub" "vhub" {
  name                = var.hub-name
  resource_group_name = var.resource-group-name
  location            = var.location
  virtual_wan_id      = var.virtual-wan-id
  address_prefix      = var.address-space

  tags = var.global-tags
}

resource "azurerm_virtual_hub_connection" "connection" {
  for_each = { for vnet in var.vnets : vnet.name => vnet.id }

  name                      = "${each.key}-to-hub-${var.hub-name}"
  virtual_hub_id            = azurerm_virtual_hub.vhub.id
  remote_virtual_network_id = each.value
}

resource "azurerm_vpn_site" "vpn" {
  for_each = { for site in var.vpn-sites : site.name => site }

  name                = each.key
  resource_group_name = var.resource-group-name
  location            = var.location
  virtual_wan_id      = var.virtual-wan-id

  address_cidrs = each.value.address-space

  dynamic "link" {
    for_each = each.value.links

    content {
      name          = link.value.name
      ip_address    = link.value.ip
      provider_name = link.value.provider
      speed_in_mbps = link.value.speed

      dynamic "bgp" {
        for_each = link.value.bgp == null ? [] : [link.value.bgp]

        content {
          asn             = bgp.value.asn
          peering_address = bgp.value.bgp_peering_address
        }
      }
    }
  }
}
