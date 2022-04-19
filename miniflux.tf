// resource "helm_release" "miniflux" {
//   name      = "miniflux"
//   namespace = "crows-moe"
// 
//   repository = "https://k8s-at-home.com/charts/"
//   chart      = "miniflux"
//   version    = "4.6.1"
// 
//   values = [
//     yamlencode({
//       env = {
//         ADMIN_USERNAME = var.miniflux.username
//         ADMIN_PASSWORD = var.miniflux.password
//         DATABASE_URL   = var.postgres.uri.miniflux
//         TZ             = "Asia/Shanghai"
//       }
//     })
//   ]
// }
// 
// resource "kubernetes_manifest" "miniflux-route" {
//   manifest = {
//     apiVersion = "traefik.containo.us/v1alpha1"
//     kind       = "IngressRoute"
//     metadata = {
//       name      = "miniflux"
//       namespace = "crows-moe"
//     }
//     spec = {
//       entryPoints = [
//         "websecure",
//       ]
//       routes = [
//         {
//           kind  = "Rule"
//           match = "Host(`rss.crows.moe`)"
//           services = [
//             {
//               name = "miniflux"
//               port = 8080
//             },
//           ]
//         },
//       ]
//       tls = {
//         certResolver = "crows-moe"
//       }
//     }
//   }
// }
