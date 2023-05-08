# resource "azurecaf_name" "nat-resource-group-name" {
#   resource_type = "azurerm_resource_group"
#   name          = "nat"
#   prefixes      = [var.tenant-short-name]
# }

# resource "azurerm_resource_group" "nat-resource-group" {
#   name     = azurecaf_name.nat-resource-group-name.result
#   location = var.location
# }

# resource "azurecaf_name" "nat-name" {
#   resource_type = "azurerm_virtual_network_gateway"
#   name          = "hub-nat"
#   prefixes      = [var.tenant-short-name]
# }

# resource "azurerm_nat_gateway" "nat" {
#   name                    = azurecaf_name.nat-name.result
#   location                = var.location
#   resource_group_name     = azurerm_resource_group.nat-resource-group.name
#   sku_name                = "Standard"
#   idle_timeout_in_minutes = 10
# }

# resource "azurerm_nat_gateway_public_ip_prefix_association" "example" {
#   for_each = { for pipp in var.public-IP-prefixes : pipp.name => pipp }

#   nat_gateway_id      = azurerm_nat_gateway.nat.id
#   public_ip_prefix_id = azurerm_public_ip_prefix.public-ip-prefix[each.value.name].id
# }
