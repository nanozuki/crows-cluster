provider "linode" {
  token = var.linode.token
}

resource "linode_lke_cluster" "crows-lke" {
  region      = "us-west"
  label       = "crows-lke"
  k8s_version = "1.21"
  pool {
    type  = "g6-standard-1"
    count = 3
  }
}
