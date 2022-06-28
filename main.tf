terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.28.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
  }
  backend "remote" {
    organization = "crows-moe"
    workspaces {
      name = "crows-moe"
    }
  }
}
