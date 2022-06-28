resource "kubernetes_service" "tachidesk" {
  metadata {
    name      = "tachidesk"
    namespace = "crows-moe"
  }
  spec {
    selector = {
      app = "tachidesk"
    }
    port {
      port = 4567
    }
  }
}

resource "kubernetes_deployment" "tachidesk" {
  metadata {
    name      = "tachidesk"
    namespace = "crows-moe"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "tachidesk"
      }
    }
    template {
      metadata {
        labels = {
          app = "tachidesk"
        }
      }
      spec {
        security_context {
          fs_group = 1000
        }
        container {
          image = "ghcr.io/suwayomi/tachidesk:v0.6.3"
          name  = "tachidesk"
          port {
            container_port = 4567
          }
          env {
            name  = "LOGGING"
            value = "out"
          }
          env {
            name  = "TZ"
            value = "Asia/Shanghai"
          }
          volume_mount {
            name       = "tachidesk-storage"
            mount_path = "/home/suwayomi/.local/share/Tachidesk"
          }
        }
        volume {
          name = "tachidesk-storage"
          persistent_volume_claim {
            claim_name = "tachidesk-storage"
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "tachidesk-storage" {
  metadata {
    name      = "tachidesk-storage"
    namespace = "crows-moe"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "linode-block-storage-retain"
  }
}

resource "kubernetes_manifest" "tachidesk-route" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "tachidesk"
      namespace = "crows-moe"
    }
    spec = {
      entryPoints = [
        "websecure",
      ]
      routes = [
        {
          kind  = "Rule"
          match = "Host(`manga.crows.moe`)"
          middlewares = [
            {
              name      = "tachidesk-auth"
              namespace = "crows-moe"
            },
          ]
          services = [
            {
              name = "tachidesk"
              port = 4567
            },
          ]
        },
      ]
      tls = {
        certResolver = "crows-moe"
      }
    }
  }
}

resource "kubernetes_manifest" "tachidesk-auth" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "tachidesk-auth"
      namespace = "crows-moe"
    }
    spec = {
      basicAuth = {
        secret = "tachidesk-auth-users"
      }
    }
  }
}

resource "kubernetes_secret" "tachidesk-auth-users" {
  metadata {
    name      = "tachidesk-auth-users"
    namespace = "crows-moe"
  }
  data = {
    users = var.traefik.tachidesk_users
  }
}
