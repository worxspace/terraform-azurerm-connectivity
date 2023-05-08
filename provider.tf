terraform {
  required_providers {
    azurerm = ">=3.40.0"
    azurecaf = {
      version = "2.0.0-preview3"
      source  = "aztfmod/azurecaf"
    }
  }
}
