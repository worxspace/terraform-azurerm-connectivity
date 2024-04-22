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

resource "azurerm_vpn_gateway" "gateway" {
  count = var.vpn-sites != [] ? 1 : 0

  name                = var.vpn-s2s-gw-name
  location            = var.location
  resource_group_name = var.resource-group-name
  virtual_hub_id      = azurerm_virtual_hub.vhub.id

  scale_unit = var.vpn-s2s-gw-sku
}

resource "azurerm_vpn_gateway_connection" "hub-connection" {
  for_each = { for site in var.vpn-sites : site.name => site }

  name               = "${each.key}-to-hub-${var.hub-name}"
  vpn_gateway_id     = azurerm_vpn_gateway.gateway[0].id
  remote_vpn_site_id = azurerm_vpn_site.vpn[each.key].id

  dynamic "vpn_link" {
    for_each = each.value.links

    content {
      name             = vpn_link.value.name
      vpn_site_link_id = azurerm_vpn_site.vpn[each.key].link[index(each.value.links, vpn_link.value)].id
    }
  }
}

resource "azurerm_point_to_site_vpn_gateway" "user-vpn" {
  count = var.user-vpn-config.enabled ? 1 : 0

  name                        = var.vpn-p2s-gw-name
  location                    = var.location
  resource_group_name         = var.resource-group-name
  virtual_hub_id              = azurerm_virtual_hub.vhub.id
  vpn_server_configuration_id = azurerm_vpn_server_configuration.vpn[0].id
  scale_unit                  = var.vpn-p2s-gw-sku
  connection_configuration {
    name = "standard"

    vpn_client_address_pool {
      address_prefixes = var.user-vpn-config.address-space
    }
  }
  dns_servers = var.user-vpn-config.dns-servers
}

data "azuread_client_config" "current" {}

resource "azuread_group" "vpn-standard-users" {
  count = var.user-vpn-config.enabled ? 1 : 0

  display_name     = var.user-vpn-config.ad-group
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

resource "azurerm_vpn_server_configuration_policy_group" "standard" {
  count = var.user-vpn-config.enabled ? 1 : 0

  name                        = "standard-policy-cfg"
  vpn_server_configuration_id = azurerm_vpn_server_configuration.vpn[0].id
  is_default                  = true
  priority                    = 1
  policy {
    name  = "standard"
    type  = "AADGroupId"
    value = azuread_group.vpn-standard-users[0].id
  }
}

resource "azurerm_vpn_server_configuration" "vpn" {
  count = var.user-vpn-config.enabled ? 1 : 0

  name                     = "vpn-config-1"
  resource_group_name      = var.resource-group-name
  location                 = var.location
  vpn_authentication_types = ["AAD"]
  azure_active_directory_authentication {
    audience = "41b23e61-6c1e-4545-b367-cd054e0ed4b4" # VPN enterprise app ID
    issuer   = "https://sts.windows.net/${var.user-vpn-config.tenant-id}/"
    tenant   = "https://login.microsoftonline.com/${var.user-vpn-config.tenant-id}"
  }
}
