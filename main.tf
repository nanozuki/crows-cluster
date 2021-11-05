terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  backend "remote" {
    organization = "crows-moe"
    workspaces {
      name = "crows-moe"
    }
  }
}
