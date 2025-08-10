terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes  = {
        source = "hashicorp/kubernetes"
        version = ">= 2.29.0"
        }
    helm        = {
        source = "hashicorp/helm"
        version = ">= 2.13.0"
        }
  }
}

provider "aws" { region = var.aws_region }
