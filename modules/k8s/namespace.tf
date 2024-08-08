resource "kubernetes_namespace" "app" {
  metadata {
    name = var.k8s_app_namespace
  }
}