terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

provider "docker" {}

# Pull image backend
resource "docker_image" "backend" {
  name         = "hashicorp/http-echo:latest"
  keep_locally = false # otomatis hapus image lama kalau tidak dipakai
}

# Run container backend
resource "docker_container" "backend" {
  name           = "backend-app"
  image          = docker_image.backend.name
  must_run       = true
  remove_volumes = true
  restart        = "no"

  lifecycle {
    replace_triggered_by = [docker_image.backend]
  }

  ports {
    internal = 5678
    external = 8083
  }

  command = [
    "-text=Hello from Terraform GitOps Backend pake runner!"
  ]
}
