#
# https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/fargate-logging.html
#

resource "kubernetes_config_map" "aws_logging" {
  metadata {
    name      = "aws-logging"
    namespace = "aws-observability"
  }

  data = {
    flb_log_cw     = "false"
    "filters.conf" = <<EOL
[FILTER]
    Name parser
    Match *
    Key_name log
    Parser crio
[FILTER]
    Name kubernetes
    Match kube.*
    Merge_Log On
    Keep_Log Off
    Buffer_Size 0
    Kube_Meta_Cache_TTL 300s
EOL
    "output.conf"  = <<EOL
[OUTPUT]
    Name cloudwatch_logs
    Match   kube.*
    region ${var.region}
    log_group_name /aws/eks/${aws_eks_cluster.eks.name}
    log_stream_prefix fluent-bit-
    log_retention_days 60
    auto_create_group true
EOL
    "parsers.conf" = <<EOL
[PARSER]
    Name crio
    Format Regex
    Regex ^(?<time>[^ ]+) (?<stream>stdout|stderr) (?<logtag>P|F) (?<log>.*)$
    Time_Key    time
    Time_Format %Y-%m-%dT%H:%M:%S.%L%z
EOL
  }
}

resource "kubernetes_namespace" "aws_observability" {
  metadata {
    name = "aws-observability"

    labels = {
      "aws-observability" = "enabled"
    }
  }
}

data "aws_iam_policy_document" "eks_fargate_logging_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "eks_fargate_logging_policy" {
  name        = "eks-fargate-logging-policy"
  description = "https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/fargate-logging.html"
  policy      = data.aws_iam_policy_document.eks_fargate_logging_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "eks_fargate_logging_policy_attachment" {
  policy_arn = aws_iam_policy.eks_fargate_logging_policy.arn
  role       = aws_iam_role.eks_fargate_pod_execution_role.name
}
