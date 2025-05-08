terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.97.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.111.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}

}

provider "aws" {
  region = "us-east-1"
  #access_key = "AKIAX5555555555555555"
  #secret_key = "5555555555555555555555555555555555555555"
}
