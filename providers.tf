terraform {
  required_version = "1.13.1"
  
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.24.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
}