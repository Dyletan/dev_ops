terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.11.0"
    }
  }
}

provider "docker" {}

provider "vault" {
  address = "http://137.184.180.202:8200"
  token   = "root" 
}

# Fetch the secret as a data source instead of a resource
data "vault_generic_secret" "hackakaton" {
  path = "secret/hackakaton"
}

resource "docker_image" "kbtu_image_to_pull" {
  name         = "postgres:latest"
  keep_locally = true
}

resource "docker_container" "kbtu_image_iwant_to_start" {
  image = docker_image.kbtu_image_to_pull.image_id
  name  = "running_devopsina"

  ports {
    internal = 5432
    external = 5434
  }

  env = [
    "POSTGRES_USER=${data.vault_generic_secret.hackakaton.data["user"]}",
    "POSTGRES_PASSWORD=${data.vault_generic_secret.hackakaton.data["password"]}",
    "POSTGRES_DB=${data.vault_generic_secret.hackakaton.data["user"]}"
  ]
}

output "container_name" {
  value = docker_container.kbtu_image_iwant_to_start.name
}

output "container_ports" {
  value = docker_container.kbtu_image_iwant_to_start.ports.0.external
}