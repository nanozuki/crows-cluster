resource "kubernetes_deployment" "vote2021-web" {
  metadata {
    name      = "vote2021-web"
    namespace = "crows-moe"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "vote2021-web"
      }
    }
    template {
      metadata {
        labels = {
          app = "vote2021-web"
        }
      }
      spec {
        container {
          image             = "ghcr.io/nanozuki/vote2021-web:1.1.0"
          name              = "vote2021-web"
          image_pull_policy = "Always"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "vote2021-web" {
  metadata {
    name      = "vote2021-web"
    namespace = "crows-moe"
  }
  spec {
    selector = {
      app = "vote2021-web"
    }
    port {
      port = 3000
    }
  }
}

resource "kubernetes_manifest" "vote2021-web-route" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "vote2021-web"
      namespace = "crows-moe"
    }
    spec = {
      entryPoints = [
        "websecure",
      ]
      routes = [
        {
          kind  = "Rule"
          match = "Host(`vote2021.crows.moe`)"
          services = [
            {
              name = "vote2021-web"
              port = 3000
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

resource "kubernetes_deployment" "vote2021-api" {
  metadata {
    name      = "vote2021-api"
    namespace = "crows-moe"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "vote2021-api"
      }
    }
    template {
      metadata {
        labels = {
          app = "vote2021-api"
        }
      }
      spec {
        container {
          image             = "ghcr.io/nanozuki/vote2021-api:1.1.0"
          name              = "vote2021-api"
          image_pull_policy = "Always"
          env {
            name  = "VOTE2021_PG"
            value = var.postgres.uri
          }
          port {
            container_port = 8000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "vote2021-api" {
  metadata {
    name      = "vote2021-api"
    namespace = "crows-moe"
  }
  spec {
    selector = {
      app = "vote2021-api"
    }
    port {
      port = 8000
    }
  }
}

resource "kubernetes_manifest" "vote2021-api-route" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "vote2021-api"
      namespace = "crows-moe"
    }
    spec = {
      entryPoints = [
        "websecure",
      ]
      routes = [
        {
          kind  = "Rule"
          match = "Host(`vote2021.crows.moe`) && PathPrefix(`/api`)"
          services = [
            {
              name = "vote2021-api"
              port = 8000
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
