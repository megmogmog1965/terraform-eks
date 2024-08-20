resource "kubernetes_config_map_v1" "aws-auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(
      [
        {
          rolearn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.full_access_role_name}"
          username : "${var.full_access_role_name}"
          groups : ["system:masters"]
        },
        {
          rolearn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.eks_fargate_pod_execution_role.name}"
          username : "system:node:{{SessionName}}"
          groups : ["system:bootstrappers", "system:nodes", "system:node-proxier"]
        }
      ]
    )
    # mapUsers = yamlencode(
    #   [
    #     {
    #       userarn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/username"
    #       username : "username"
    #       groups : ["${kubernetes_cluster_role.full_access.metadata[0].name}"]
    #     }
    #   ]
    # )
  }
}