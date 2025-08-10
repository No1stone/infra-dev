# 노드가 실제 올라갈 서브넷들만 타겟
locals {
  target_node_subnets = length(var.node_subnet_ids) > 0 ? var.node_subnet_ids : [var.private_subnet_ids[0]]
}

# 각 서브넷의 RTB 조회
data "aws_route_table" "nodes" {
  for_each  = toset(local.target_node_subnets)
  subnet_id = each.value
}


# 0.0.0.0/0 -> NAT 인스턴스(의 ENI)로 라우트
resource "aws_route" "nodes_default_to_nat" {
  for_each               = data.aws_route_table.nodes
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = data.aws_instance.nat.network_interface_id


  lifecycle {
    create_before_destroy = true
  }
}
