resource "kubernetes_namespace" "ingress_nginx" {
  provider = kubernetes.eks
  metadata { name = "ingress-nginx" }
  depends_on = [aws_eks_cluster.this]
}

resource "helm_release" "ingress_nginx" {
  provider  = helm.eks
  name      = "ingress-nginx"
  namespace = kubernetes_namespace.ingress_nginx.metadata[0].name

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.3" # controller v1.11.x 계열(EKS 1.30 호환)

  values = [yamlencode({
    controller = {
      ingressClassResource = {
        name    = "nginx"
        enabled = true
        default = true
      }
      # ALB 안 쓰고 단순 라우팅이면 NodePort
      service = {
        type = "NodePort"
        nodePorts = {
          http  = 30080
          https = 30443
        }
      }
      watchNamespace = ""   # 전체 네임스페이스 감시
    }
  })]

  depends_on = [
    kubernetes_namespace.ingress_nginx,
    aws_eks_cluster.this
  ]
}
