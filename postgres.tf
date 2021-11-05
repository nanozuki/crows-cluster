resource "helm_release" "postgres" {
  name      = "postgres"
  namespace = "crows-moe"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "10.13.4"

  values = [
    yamlencode({
      global = {
        postgresql = {
          postgresqlDatabase = var.postgres.database
          postgresqlPassword = var.postgres.password
          postgresqlUsername = var.postgres.username
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
