provider "kubernetes" {
  config_path    = "~/.config/kube/config-crows-lke"
  config_context = var.linode.cluster_context
  experiments {
    manifest_resource = true
  }
}

resource "kubernetes_namespace" "crows-moe" {
  metadata {
    name = "crows-moe"
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.config/kube/config-crows-lke"
  }
}
