module "eks" {
  source = "./modules/eks"

  region                = var.region
  full_access_role_name = var.full_access_role_name
}

#module "k8s" {
#  source     = "./modules/k8s"
#  depends_on = [module.eks]
#
#  region             = var.region
#  k8s_app_namespace  = var.k8s_app_namespace
#  alb_certificate_id = var.alb_certificate_id
#}
