# terraform-eks

Amazon EKS と Kubernetes 上のリソースを全て Terraform だけで管理する.
必要最小限のランタイムリソースに抑えるために、外部 module や eksctl は使用しない.

| Modules | Description |
|:--- |:--- |
| eks | Amazon EKS Cluster を構築する. |
| k8s | Kubernetes のリソース (Deployment, Service, Ingress...) を構築する. |
