# 예시: 기존 네트워크 data 참조 (문법 정리)
data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnet" "private" {
  for_each = toset(var.private_subnet_ids)
  id       = each.value
}

data "aws_subnet" "public" {
  for_each = toset(var.public_subnet_ids)
  id       = each.value
}

data "aws_instance" "nat" {
  instance_id = var.nat_instance_id
}

locals {
  cluster_subnet_ids       = var.private_subnet_ids
  effective_node_subnet_ids = length(var.node_subnet_ids) > 0 ? var.node_subnet_ids : [var.private_subnet_ids[0]]
}
# (필요 시) 관리 전환용 resource + import + prevent_destroy 는 이전 답변 그대로 사용
