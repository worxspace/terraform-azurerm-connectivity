output "hub-vnet-resource-group-name" {
  value = azurerm_resource_group.connectivity-resource-group.name
  description = "name of the hub resource group"
}

output "hub-vnet-name" {
  value = azurerm_virtual_network.hub-vnet.name
  description = "name of the hub vnet"
}

output "hub-vnet-id" {
  value = azurerm_virtual_network.hub-vnet.id
  description = "resource id of the hub vnet"
}

output "public-IPs" {
  value = {
    for key, pip in azurerm_public_ip.public-ip : key => pip
  }
  description = "map of public IPs"
}

output "public-ip-prefixes" {
  value = {
    for key, pip in azurerm_public_ip_prefix.public-ip-prefix : key => pip
  }
  description = "map of public IP prefixes"
}