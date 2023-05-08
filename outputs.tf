output "hub-vnet-resource-group-name" {
  value = azurerm_resource_group.connectivity-resource-group.name
}

output "hub-vnet-name" {
  value = azurerm_virtual_network.hub-vnet.name
}

output "hub-vnet-id" {
  value = azurerm_virtual_network.hub-vnet.id
}

output "public-IPs" {
  value = {
    for key, pip in azurerm_public_ip.public-ip : key => pip
  }
}
