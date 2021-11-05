resource "kubernetes_deployment" "crows-moe-fe" {
  metadata {
    name      = "crows-moe-fe"
    namespace = "crows-moe"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "crows-moe-fe"
      }
    }
    template {
      metadata {
        labels = {
          app = "crows-moe-fe"
        }
      }
      spec {
        container {
          image             = "ghcr.io/nanozuki/crows-moe:v1.0.0"
          name              = "crows-moe"
          image_pull_policy = "Always"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "crows-moe-fe" {
  metadata {
    name      = "crows-moe-fe"
    namespace = "crows-moe"
  }
  spec {
    selector = {
      app = "crows-moe-fe"
    }
    port {
      port = 80
    }
  }
}

resource "kubernetes_manifest" "crows-moe-fe-route" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "crows-moe-fe"
      namespace = "crows-moe"
    }
    spec = {
      entryPoints = [
        "websecure",
      ]
      routes = [
        {
          kind  = "Rule"
          match = "Host(`crows.moe`)"
          services = [
            {
              name = "crows-moe-fe"
              port = 80
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
