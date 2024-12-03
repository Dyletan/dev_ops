job "my-service" {
  datacenters = ["kbtu"]

  group "service" {
    count = 3

    task "web" {
      driver = "docker"

      config {
        image = "my-service:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 500
        memory = 256
      }

      service {
        name = "my-service"
        tags = ["urlprefix-/"]
        port = "http"

        check {
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    network {
      port "http" {
        static = 8080
      }
    }
  }
}
