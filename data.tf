data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.eks_cluster_name
}

data "aws_caller_identity" "current" {}
