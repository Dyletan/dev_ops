terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {}

resource "docker_image" "kbtu_image_to_pull" {
  name         = "postgres:latest"
  keep_locally = true
}

resource "docker_container" "kbtu_image_iwant_to_start" {
  image = docker_image.kbtu_image_to_pull.image_id
  name  = "task2_test_db"

  ports {
    internal = 5432
    external = 5434
  }

  env = [
    "POSTGRES_USER=postgres",
    "POSTGRES_PASSWORD=pass",
    "POSTGRES_DB=postgres"
  ]
}

output "container_name" {
  value = docker_container.kbtu_image_iwant_to_start.name
}

output "container_ports" {
  value = docker_container.kbtu_image_iwant_to_start.ports.0.external
}