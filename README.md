# tfm-azure-connectivity

Creates connectivity hub in azure in a standardised way using the latest recommendations.

We use azurecaf\_name to generate a unique name for the user assigned identity.
so make sure to provide the project-name, prefixes, suffixes as necessary

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurecaf"></a> [azurecaf](#requirement\_azurecaf) | >=2.0.0-preview3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.40.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurecaf"></a> [azurecaf](#provider\_azurecaf) | >=2.0.0-preview3 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.40.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_public-dns"></a> [public-dns](#module\_public-dns) | github.com/worxspace/tfm-azure-publicdnszone | 0.0.2 |

## Resources

| Name | Type |
|------|------|
| [azurecaf_name.bastion-name](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.hub-name](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.public-dns-resource-group-name](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.public-ip-name](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.public-ip-prefix-name](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.public-ip-resource-group-name](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurerm_bastion_host.bastion-basic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |
| [azurerm_bastion_host.bastion-std](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |
| [azurerm_public_ip.bastion-ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.public-ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip_prefix.public-ip-prefix](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip_prefix) | resource |
| [azurerm_resource_group.bastion-resource-group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.connectivity-resource-group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.public-dns-resource-group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.public-ip-resource-group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.bastion-subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.hub-vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion-configuration"></a> [bastion-configuration](#input\_bastion-configuration) | specific settings for the configuration of Azure Bastion | <pre>object({<br>    sku = optional(string, "Standard")<br>    scale_units = optional(number, 2)<br>    copy_paste_enabled = optional(bool, true)<br>    file_copy_enabled  = optional(bool, false)<br>    ip_connect_enabled = optional(bool, false)<br>    shareable_link_enabled = optional(bool, false)<br>    tunneling_enabled = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_bastion-subnet-space"></a> [bastion-subnet-space](#input\_bastion-subnet-space) | address space assigned to the bastion subnet | `string` | `null` | no |
| <a name="input_global-tags"></a> [global-tags](#input\_global-tags) | tags to be applied to all resources | `map(string)` | `{}` | no |
| <a name="input_hub-vnet-address-space"></a> [hub-vnet-address-space](#input\_hub-vnet-address-space) | address space assigned to the hub vnet | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | value for the location of the virtual machines | `string` | `"switzerlandnorth"` | no |
| <a name="input_project-name"></a> [project-name](#input\_project-name) | used as the main part of the name of the virtual machine | `string` | n/a | yes |
| <a name="input_public-DNS-Zones"></a> [public-DNS-Zones](#input\_public-DNS-Zones) | values to be used for the creation of public DNS zones | <pre>list(object({<br>    name = string<br>    soa-record = optional(object({<br>      email         = string<br>      host-name     = string<br>      expire-time   = optional(number)<br>      minimum-ttl   = optional(number)<br>      refresh-time  = optional(number)<br>      retry-time    = optional(number)<br>      serial-number = optional(number)<br>      ttl           = optional(number)<br>      tags          = optional(map(string))<br>    }))<br>    A-records = optional(list(object({<br>      name    = string<br>      ttl     = number<br>      records = list(string)<br>    })))<br>    NS-records = optional(list(object({<br>      name    = string<br>      ttl     = number<br>      records = list(string)<br>    })))<br>    MX-records = optional(list(object({<br>      name = string<br>      ttl  = number<br>      records = list(object({<br>        preference = number<br>        exchange   = string<br>      }))<br>    })))<br>    TXT-records = optional(list(object({<br>      name    = string<br>      ttl     = number<br>      records = list(string)<br>    })))<br>    CNAME-records = optional(list(object({<br>      name   = string<br>      ttl    = number<br>      record = string<br>    })))<br>    SRV-records = optional(list(object({<br>      name = string<br>      ttl  = number<br>      record = object({<br>        priority = number<br>        weight   = number<br>        port     = number<br>        target   = string<br>      })<br>    })))<br>  }))</pre> | `null` | no |
| <a name="input_public-IP-prefixes"></a> [public-IP-prefixes](#input\_public-IP-prefixes) | values to be used for the creation of public IP prefixes | <pre>list(object({<br>    name          = string<br>    prefix-length = number<br>    tags          = optional(map(string))<br>  }))</pre> | `null` | no |
| <a name="input_public-IPs"></a> [public-IPs](#input\_public-IPs) | values to be used for the creation of public IPs | <pre>list(object({<br>    name              = string<br>    allocation-method = optional(string, "Static")<br>    sku               = optional(string, "Standard")<br>  }))</pre> | `null` | no |
| <a name="input_resource-group-name"></a> [resource-group-name](#input\_resource-group-name) | resource group where you want to create the virtual machines | `string` | n/a | yes |
| <a name="input_resource-prefixes"></a> [resource-prefixes](#input\_resource-prefixes) | these are prefixed to resource names and usually include the tenant short name and/or the environment name | `list(string)` | `[]` | no |
| <a name="input_resource-suffixes"></a> [resource-suffixes](#input\_resource-suffixes) | these are appended to resource names and usually include the numbers when multiple resource with the same name exist | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hub-vnet-id"></a> [hub-vnet-id](#output\_hub-vnet-id) | resource id of the hub vnet |
| <a name="output_hub-vnet-name"></a> [hub-vnet-name](#output\_hub-vnet-name) | name of the hub vnet |
| <a name="output_hub-vnet-resource-group-name"></a> [hub-vnet-resource-group-name](#output\_hub-vnet-resource-group-name) | name of the hub resource group |
| <a name="output_public-IPs"></a> [public-IPs](#output\_public-IPs) | map of public IPs |
| <a name="output_public-ip-prefixes"></a> [public-ip-prefixes](#output\_public-ip-prefixes) | map of public IP prefixes |
