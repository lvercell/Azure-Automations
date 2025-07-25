terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.79.0"
    }
  }

  required_version = ">= 1.4.0"
}

provider "azurerm" {
  features {}
}
