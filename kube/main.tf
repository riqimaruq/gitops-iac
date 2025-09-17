provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Namespace
resource "kubernetes_namespace" "backend" {
  metadata {
    name = "backend-app"
  }
}

# Deployment
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
          image = "nginx:latest" # ganti dengan image aplikasi kamu

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

# Service (NodePort)
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
      name        = "http"
      port        = 8084   # service port
      target_port = 8084   # container port
      node_port   = 30084  # port di node
    }

    type = "NodePort"
  }
}
