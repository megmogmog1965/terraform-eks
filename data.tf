data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_caller_identity" "current" {}
