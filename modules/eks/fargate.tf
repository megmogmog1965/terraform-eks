resource "aws_eks_fargate_profile" "fargate_profile" {
  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = "my-fargate-profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_execution_role.arn

  subnet_ids = aws_subnet.eks_private_subnet[*].id

  selector {
    namespace = "*"
  }

  tags = {
    Name = "my-fargate-profile"
  }

  depends_on = [
    kubernetes_config_map_v1.aws-auth
  ]
}

resource "aws_iam_role" "eks_fargate_pod_execution_role" {
  name = "eksFargatePodExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_fargate_pod_execution_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_pod_execution_role.name
}

# @fixme (環境依存...)
# EKS を構築した直後に CoreDNS Pods が起動するが、まだ Fargate profile が設定されていないため Pod が Pending に.
resource "null_resource" "restart_coredns" {
  provisioner "local-exec" {
    command = <<EOT
    kubectl rollout restart deployment coredns -n kube-system
    EOT
  }

  depends_on = [
    aws_eks_fargate_profile.fargate_profile
  ]
}
