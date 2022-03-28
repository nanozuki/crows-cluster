# helm chart
resource "helm_release" "traefik" {
  name      = "traefik"
  namespace = "crows-moe"

  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "10.16.0"

  values = [
    yamlencode({
      additionalArguments = [
        "--log.level=INFO",
        "--api.dashboard=true",
        "--certificatesresolvers.crows-moe.acme.dnschallenge=true",
        "--certificatesresolvers.crows-moe.acme.dnschallenge.provider=cloudflare",
        format("--certificatesresolvers.crows-moe.acme.email=%s", var.cf_api.email),
        "--certificatesresolvers.crows-moe.acme.storage=/data/acme.json",
        format("--pilot.token=%s", var.traefik.pilot_token),
      ]
      env = [
        {
          name  = "CF_API_EMAIL"
          value = var.cf_api.email
        },
        {
          name  = "CF_API_KEY"
          value = var.cf_api.key
        },
      ]
      ingressRoute = {
        dashboard = {
          enabled = false
        }
      }
      ports = {
        postgres = {
          expose      = true
          exposedPort = var.postgres.external_port
          port        = var.postgres.external_port
          protocol    = "TCP"
        }
        traefik = {
          expose      = true
          exposedPort = 9000
          port        = 9000
          protocol    = "TCP"
        }
        web = {
          expose      = true
          exposedPort = 80
          port        = 8000
          protocol    = "TCP"
        }
        websecure = {
          expose      = true
          exposedPort = 443
          port        = 8443
          protocol    = "TCP"
        }
      }
    }),
  ]
}

resource "kubernetes_manifest" "traefik-dashboard" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "traefik-dashboard"
      namespace = "crows-moe"
    }
    spec = {
      entryPoints = [
        "websecure",
      ]
      routes = [
        {
          kind  = "Rule"
          match = "Host(`crows.moe`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))"
          middlewares = [
            {
              name      = "dashboard-auth"
              namespace = "crows-moe"
            },
          ]
          services = [
            {
              kind = "TraefikService"
              name = "api@internal"
              port = 8080
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

resource "kubernetes_manifest" "traefik-dashboard-auth" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "dashboard-auth"
      namespace = "crows-moe"
    }
    spec = {
      basicAuth = {
        secret = "dashboard-auth-users"
      }
    }
  }
}

resource "kubernetes_secret" "traefik-dashboard-auth-users" {
  metadata {
    name      = "dashboard-auth-users"
    namespace = "crows-moe"
  }
  data = {
    users = var.traefik.dashboard_users
  }
}
