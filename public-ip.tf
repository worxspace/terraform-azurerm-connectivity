resource "azurecaf_name" "public-ip-resource-group-name" {
  resource_type = "azurerm_resource_group"
  name          = "public-ip"
  prefixes      = [var.tenant-short-name]
}

resource "azurerm_resource_group" "public-ip-resource-group" {
  name     = azurecaf_name.public-ip-resource-group-name.result
  location = var.location

  tags = var.global-tags
}

resource "azurecaf_name" "public-ip-prefix-name" {
  for_each = var.public-IP-prefixes == null ? {} : { for pipp in var.public-IP-prefixes : pipp.name => pipp }

  resource_type = "azurerm_public_ip_prefix"
  name          = each.value.name
  prefixes      = [var.tenant-short-name]
}

resource "azurerm_public_ip_prefix" "public-ip-prefix" {
  for_each = var.public-IP-prefixes == null ? {} : { for pipp in var.public-IP-prefixes : pipp.name => pipp }

  name                = azurecaf_name.public-ip-prefix-name[each.value.name].result
  location            = var.location
  resource_group_name = azurerm_resource_group.public-ip-resource-group.name
  prefix_length       = each.value.prefix-length
  
  tags                = each.value.tags
}

resource "azurecaf_name" "public-ip-name" {
  for_each = var.public-IPs == null ? {} : { for pip in var.public-IPs : pip.name => pip }

  resource_type = "azurerm_public_ip"
  name     = each.value.name
  prefixes = [var.tenant-short-name]
}

resource "azurerm_public_ip" "public-ip" {
  for_each = var.public-IPs == null ? {} : { for pip in var.public-IPs : pip.name => pip }

  resource_group_name = azurerm_resource_group.public-ip-resource-group.name
  name                = azurecaf_name.public-ip-name[each.value.name].result
  location            = var.location
  allocation_method   = each.value.allocation-method
  sku                 = each.value.sku
}
