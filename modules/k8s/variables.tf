variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "k8s_app_namespace" {
  description = "Application namespace in Kubernetes cluster"
  type        = string
  default     = "my-namespace"
}

variable "alb_certificate_id" {
  description = "ID of the ACM certificate for the ALB"
  type        = string
}