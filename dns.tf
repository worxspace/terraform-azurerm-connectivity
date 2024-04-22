resource "azurecaf_name" "public-dns-resource-group-name" {
  resource_type = "azurerm_resource_group"
  name          = "${var.project-name}_dns"
  prefixes      = var.resource-prefixes
  suffixes      = concat(var.resource-suffixes, ["001"])
}

resource "azurerm_resource_group" "public-dns-resource-group" {
  name     = azurecaf_name.public-dns-resource-group-name.result
  location = var.location

  tags = var.global-tags
}

module "public-dns" {
  source  = "app.terraform.io/worxspace/publicdnszone/azurerm"
  version = "~>0.0.2"

  for_each = var.public-DNS-Zones == null ? {} : { for dns in var.public-DNS-Zones : dns.name => dns }

  name                = each.key
  resource-group-name = azurerm_resource_group.public-dns-resource-group.name
  soa-record          = can(each.value.soa-record) ? each.value.soa-record : null
  A-records           = can(each.value.A-records) ? each.value.A-records : null
  CNAME-records       = can(each.value.CNAME-records) ? each.value.CNAME-records : null
  NS-records          = can(each.value.NS-records) ? each.value.NS-records : null
  MX-records          = can(each.value.MX-records) ? each.value.MX-records : null
  TXT-records         = can(each.value.TXT-records) ? each.value.TXT-records : null
  SRV-records         = can(each.value.SRV-records) ? each.value.SRV-records : null

  global-tags = var.global-tags
}
