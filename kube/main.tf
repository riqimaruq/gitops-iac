terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config" # atau pakai env var KUBECONFIG
}

# Namespace untuk backend
resource "kubernetes_namespace" "backend" {
  metadata {
    name = "backend-app"
  }
}

 lifecycle {
    prevent_destroy = false
    ignore_changes  = [metadata]
  }
}

# Deployment backend sederhana
resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend-deployment"
    namespace = kubernetes_namespace.backend.metadata[0].name
    labels = {
      app = "backend"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "backend"
        }
      }
      spec {
        container {
          name  = "backend"
          image = "hashicorp/http-echo:latest"
          args  = [
            "-text=Hello from Backend on K8s via Terraform!",
            "-listen=:8084"
          ]
          port {
            container_port = 8084
          }
        }
      }
    }
  }
}

# Service untuk expose backend di port 8084
resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend-service"
    namespace = kubernetes_namespace.backend.metadata[0].name
  }

  spec {
    selector = {
      app = "backend"
    }

    port {
      port        = 8084
      target_port = 8084
    }

    type = "NodePort"
  }
}

output "backend_service_url" {
  value = "http://localhost:8084"
}
