terraform {
  required_providers {
    azurerm = {
      version = ">=3.40.0"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      version = ">=2.0.0-preview3"
      source  = "aztfmod/azurecaf"
    }
    azuread = {
      version = ">=2.34.2"
      source  = "hashicorp/azuread"
    }
  }
}
