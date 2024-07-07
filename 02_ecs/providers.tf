terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.56.1"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

data "terraform_remote_state" "state1" {
  backend = "local"

  config = {
    path = "../01_network/terraform.tfstate"
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
