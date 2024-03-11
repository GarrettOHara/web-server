terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.5"
}

provider "aws" {
  profile = "default"
  region  = var.region
}
