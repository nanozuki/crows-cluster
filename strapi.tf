resource "kubernetes_deployment" "strapi" {
  metadata {
    name      = "strapi"
    namespace = "crows-moe"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "strapi"
      }
    }
    template {
      metadata {
        labels = {
          app = "strapi"
        }
      }
      spec {
        container {
          image             = "ghcr.io/nanozuki/crows-moe-cms:v1.0.0"
          name              = "crows-moe-cms"
          image_pull_policy = "Always"
          port {
            container_port = 1337
          }
          env {
            name  = "DATABASE_CLIENT"
            value = "postgres"
          }
          env {
            name  = "DATABASE_NAME"
            value = "strapi"
          }
          env {
            name  = "DATABASE_HOST"
            value = "postgres-postgresql"
          }
          env {
            name  = "DATABASE_PORT"
            value = 5432
          }
          env {
            name  = "DATABASE_USERNAME"
            value = var.postgres.username
          }
          env {
            name  = "DATABASE_PASSWORD"
            value = var.postgres.password
          }
          env {
            name  = "STORAGE_ACCESS_KEY"
            value = var.linode.storage.access_key
          }
          env {
            name  = "STORAGE_SECRET_KEY"
            value = var.linode.storage.secret_key
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "strapi" {
  metadata {
    name      = "strapi"
    namespace = "crows-moe"
  }
  spec {
    selector = {
      app = "strapi"
    }
    port {
      port = 1337
    }
  }
}

resource "kubernetes_manifest" "strapi-route" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "strapi"
      namespace = "crows-moe"
    }
    spec = {
      entryPoints = [
        "websecure",
      ]
      routes = [
        {
          kind  = "Rule"
          match = "Host(`strapi.crows.moe`)"
          services = [
            {
              name = "strapi"
              port = 1337
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
