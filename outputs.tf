output "hub-vnet-resource-group-name" {
  value = azurerm_resource_group.connectivity-resource-group.name
  description = "name of the hub resource group"
}

output "bastion-vnet-name" {
  value = azurerm_virtual_network.bastion.name
  description = "name of the bastion vnet"
}

output "bastion-vnet-id" {
  value = azurerm_virtual_network.bastion.id
  description = "resource id of the bastion vnet"
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