terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 3.74"
    }
  }

  required_version = ">= 0.14.9"
}


provider "aws" {
  region = var.region
  profile = var.profile
}
