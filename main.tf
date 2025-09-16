terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

provider "docker" {}

# Pull image backend (contoh pakai image golang echo server)
resource "docker_image" "backend" {
  name = "hashicorp/http-echo:latest"
}

# Run container backend
resource "docker_container" "backend" {
  name  = "backend-app"
  image = docker_image.backend.name

  ports {
    internal = 5678
    external = 8083
  }

  command = [
    "-text=Hello from Terraform GitOps Backend!"
  ]
}
