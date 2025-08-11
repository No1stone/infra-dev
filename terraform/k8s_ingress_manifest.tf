# 1) NS는 별도 리소스로 먼저 생성
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = { "app.kubernetes.io/name" = "ingress-nginx" }
  }
}

# 2) 멀티 도큐먼트 YAML 분리 + Namespace 문서는 제외
locals {
  ingress_docs_raw = split("\n---\n", file("${path.module}/../k8s/ingress-nginx.yaml"))
  ingress_docs     = [for d in local.ingress_docs_raw : yamldecode(d) if trimspace(d) != ""]
  ingress_docs_wo_ns = [
    for d in local.ingress_docs : d
    if !(try(d.kind, "") == "Namespace")
  ]
}

# 3) 나머지 리소스는 NS에 의존
resource "kubernetes_manifest" "ingress_nginx" {
  for_each = {
    for idx, doc in local.ingress_docs_wo_ns :
    idx => doc
  }
  manifest   = each.value
  depends_on = [kubernetes_namespace.ingress_nginx]
}
