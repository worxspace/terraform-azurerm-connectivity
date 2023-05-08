variable "resource-group-name" {
  description = "resource group where you want to create the virtual machines"
  type        = string
}

variable "location" {
  type        = string
  default     = "switzerlandnorth"
  description = "value for the location of the virtual machines"
}

variable "project-name" {
  type        = string
  description = "used as the main part of the name of the virtual machine"
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

variable "hub-vnet-address-space" {
  type = list(string)
  description = "address space assigned to the hub vnet"
}

variable "bastion-subnet-space" {
  type    = string
  default = null
  description = "address space assigned to the bastion subnet"
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
  default = null
  description = "values to be used for the creation of public DNS zones"
}

variable "public-IP-prefixes" {
  type = list(object({
    name          = string
    prefix-length = number
    tags          = optional(map(string))
  }))
  default = null
  description = "values to be used for the creation of public IP prefixes"
}

variable "public-IPs" {
  type = list(object({
    name              = string
    allocation-method = optional(string, "Static")
    sku               = optional(string, "Standard")
  }))
  default = null
  description = "values to be used for the creation of public IPs"
}

variable "bastion-configuration" {
  type = object({
    sku = optional(string, "Standard")
    scale_units = optional(number, 2)
    copy_paste_enabled = optional(bool, true)
    file_copy_enabled  = optional(bool, false)
    ip_connect_enabled = optional(bool, false)
    shareable_link_enabled = optional(bool, false)
    tunneling_enabled = optional(bool, false)
  })
  default = null
  description = "specific settings for the configuration of Azure Bastion"
}

variable "global-tags" {
  type        = map(string)
  default     = {}
  description = "tags to be applied to all resources"
}