variable "location" {
  type        = string
  default     = "switzerlandnorth"
  description = "value for the location of the resources"
}

variable "project-name" {
  type        = string
  description = "used as the main part of the name of the resources"
}

variable "resource-prefixes" {
  type        = list(string)
  description = "these are prefixed to resource names and usually include the tenant short name and/or the environment name"

  default = []
}

variable "resource-suffixes" {
  type        = list(string)
  description = "these are appended to resource names and usually include the numbers when multiple resource with the same name exist"

  default = []
}

variable "hubs" {
  type = list(object({
    name          = string
    address-space = string
    vnets = list(object({
      name = string
      id   = string
    }))
    vpn-sites = list(object({
      name          = string
      address-space = optional(list(string), null)
      links = list(object({
        name     = string
        ip       = string
        provider = string
        speed    = string
        bgp = optional(object({
          asn                 = number
          bgp_peering_address = string
        }), null)
      }))
    }))
    user-vpn-config = optional(object({
      tenant-id     = string
      ad-group-name = string
      address-space = list(string)
      dns-servers   = list(string)
    }), {
      tenant-id     = null
      ad-group-name = null
      address-space = []
      dns-servers   = []
    })
  }))
  default     = []
  description = "list of vpn sites to be connected to the virtual hub"
}

variable "bastion-address-space" {
  type        = string
  default     = null
  description = "address space assigned to the bastion"
}

variable "public-DNS-Zones" {
  type = list(object({
    name = string
    soa-record = optional(object({
      email         = string
      host-name     = string
      expire-time   = optional(number)
      minimum-ttl   = optional(number)
      refresh-time  = optional(number)
      retry-time    = optional(number)
      serial-number = optional(number)
      ttl           = optional(number)
      tags          = optional(map(string))
    }))
    A-records = optional(list(object({
      name    = string
      ttl     = number
      records = list(string)
    })))
    NS-records = optional(list(object({
      name    = string
      ttl     = number
      records = list(string)
    })))
    MX-records = optional(list(object({
      name = string
      ttl  = number
      records = list(object({
        preference = number
        exchange   = string
      }))
    })))
    TXT-records = optional(list(object({
      name    = string
      ttl     = number
      records = list(string)
    })))
    CNAME-records = optional(list(object({
      name   = string
      ttl    = number
      record = string
    })))
    SRV-records = optional(list(object({
      name = string
      ttl  = number
      record = object({
        priority = number
        weight   = number
        port     = number
        target   = string
      })
    })))
  }))
  default     = null
  description = "values to be used for the creation of public DNS zones"
}

variable "public-IP-prefixes" {
  type = list(object({
    name          = string
    prefix-length = number
    tags          = optional(map(string))
  }))
  default     = null
  description = "values to be used for the creation of public IP prefixes"
}

variable "public-IPs" {
  type = list(object({
    name              = string
    allocation-method = optional(string, "Static")
    sku               = optional(string, "Standard")
  }))
  default     = null
  description = "values to be used for the creation of public IPs"
}

variable "bastion-configuration" {
  type = object({
    sku                    = optional(string, "Standard")
    scale_units            = optional(number, 2)
    copy_paste_enabled     = optional(bool, true)
    file_copy_enabled      = optional(bool, false)
    ip_connect_enabled     = optional(bool, false)
    shareable_link_enabled = optional(bool, false)
    tunneling_enabled      = optional(bool, false)
  })
  default     = null
  description = "specific settings for the configuration of Azure Bastion"
}

variable "global-tags" {
  type        = map(string)
  default     = {}
  description = "tags to be applied to all resources"
}
