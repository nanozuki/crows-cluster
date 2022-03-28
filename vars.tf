variable "linode" {
  type = object({
    token = string
    storage = object({
      access_key = string
      secret_key = string
    })
    cluster_context = string
  })
  sensitive = true
}

variable "cf_api" {
  type = object({
    email = string
    key   = string
  })
  sensitive = true
}

variable "traefik" {
  type = object({
    pilot_token     = string
    dashboard_users = string
  })
  sensitive = true
}

variable "postgres" {
  type = object({
    external_port = number
    database      = string
    username      = string
    password      = string
    uri           = string
  })
  sensitive = true
}
