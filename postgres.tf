resource "helm_release" "postgres" {
  name      = "postgres"
  namespace = "crows-moe"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "11.1.20"

  values = [
    yamlencode({
      global = {
        postgresql = {
          auth = {
            postgresPassword = var.postgres.password
            database         = var.postgres.database
            password         = var.postgres.password
            username         = var.postgres.username
            existingSecret   = "postgres-postgresql"
          }
        }
      }
    })
  ]
}

resource "kubernetes_manifest" "postgres-route" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRouteTCP"
    metadata = {
      name      = "postgres-route"
      namespace = "crows-moe"
    }
    spec = {
      entryPoints = [
        "postgres",
      ]
      routes = [
        {
          match = "HostSNI(`*`)"
          services = [
            {
              name             = "postgres-postgresql"
              port             = 5432
              terminationDelay = 400
            },
          ]
        },
      ]
    }
  }
}
