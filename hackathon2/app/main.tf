terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}
provider "docker" {}

variable "db_name" {
  description = "The name of the PostgreSQL database"
  type        = string
  default     = "postgres"
}

variable "db_user" {
  description = "The PostgreSQL username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "The PostgreSQL password"
  type        = string
  default     = "postgres"
  sensitive   = true
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
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}"
  ]
}

output "container_name" {
  value = docker_container.kbtu_image_iwant_to_start.name
}

output "container_ports" {
  value = docker_container.kbtu_image_iwant_to_start.ports.0.external
}
