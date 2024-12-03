job "traefik" {
  datacenters = ["kbtu"]
  type = "system"

  group "traefik" {
    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v2.7"
        args = [
          "--providers.consulCatalog=true",
          "--entrypoints.web.address=:80",
          "--log.level=INFO",
          "--api.insecure=true"
        ]
      }

      resources {
        cpu    = 500
        memory = 256
      }

      service {
        name = "traefik"
        tags = ["traefik"]
        port = "http"
      }

      network {
        port "http" {
          static = 80
        }
      }
    }
  }
}
