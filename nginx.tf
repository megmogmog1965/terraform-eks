resource "kubernetes_namespace" "nginx" {
  metadata {
    name = var.k8s_app_namespace
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-deployment"
    namespace = kubernetes_namespace.nginx.metadata[0].name
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

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace.nginx.metadata[0].name
    labels = {
      app = "nginx"
    }
    # annotations = {
    #   "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
    #   "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
    # }
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "nginx" {
  metadata {
    name      = "nginx-ingress"
    namespace = kubernetes_namespace.nginx.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([{ "HTTP" : 80, "HTTPS" : 443 }])
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:${var.region}:${data.aws_caller_identity.current.account_id}:certificate/${var.alb_certificate_id}"
      "alb.ingress.kubernetes.io/ssl-policy"      = "ELBSecurityPolicy-2016-08"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.nginx.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
