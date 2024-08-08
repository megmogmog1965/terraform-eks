resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-deployment"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          resources {
            requests = {
              cpu    = "256m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "512m"
              memory = "1Gi"
            }
          }

          port {
            container_port = 80
          }
        }
      }
    }
  }
}
