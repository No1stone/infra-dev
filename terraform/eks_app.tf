data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}


provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  alias                  = "eks"
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}


# 네임스페이스 생성
resource "kubernetes_namespace" "gateway" {
  metadata {
    name = "gateway"
  }
}
resource "kubernetes_namespace" "resource" {
  metadata { name = "resource" }
}

# Ingress NGINX 설치
# resource "helm_release" "ingress_nginx" {
#   name       = "ingress-nginx"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   namespace  = "ingress-nginx"
#   create_namespace = true
#
#   set = [
#     {
#       name  = "controller.replicaCount"
#       value = "2"
#     },
#     {
#       name  = "controller.service.type"
#       value = "LoadBalancer"
#     }
#   ]
# }
#

