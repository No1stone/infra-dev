output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}
output "cluster_name" {
  value = aws_eks_cluster.this.name
}
output "cluster_arn" {
  value = aws_eks_cluster.this.arn
}
output "cluster_status" {
  value = aws_eks_cluster.this.status
}
