variable "cluster_name" {
  description = "EKS Cluster name"
  default     = "spring-eks-dev"
}

# AZ 선택 (ap-northeast-2 예시)
variable "primary_az"  { default = "ap-northeast-2a" }
variable "secondary_az"{ default = "ap-northeast-2b" }
variable "cluster_version"         {
    type = string
    default = "1.25"
    }
# variable "eks_cluster_role_arn"    { type = string } # 이미 만든 클러스터 롤 ARN
# variable "eks_node_role_arn"       { type = string } # 이미 만든 노드 롤 ARN

resource "aws_subnet" "eks_private_primary" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = var.primary_az
  map_public_ip_on_launch = false
  tags = {
    Name                                   = "${var.cluster_name}-private-${var.primary_az}"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# 사용안함
resource "aws_subnet" "eks_private_secondary_tiny" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.20.0/28" # 최소 /28 껍데기
  availability_zone       = var.secondary_az
  map_public_ip_on_launch = false
  tags = {
    Name                                   = "${var.cluster_name}-private-${var.secondary_az}-tiny"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids = [
      aws_subnet.eks_private_primary.id,
      aws_subnet.eks_private_secondary_tiny.id
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}

resource "aws_eks_node_group" "primary_only" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-primary"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = [aws_subnet.eks_private_primary.id] # a만

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  update_config { max_unavailable = 1 }
  capacity_type = "ON_DEMAND"
  ami_type      = "AL2_x86_64"
}

variable "vpc_id" {
  type    = string
  default = "vpc-00fae3f8256a9cd22"
}

variable "subnet_ids" {
  type = list(string)
  default = [
    "subnet-03906d593e24a05b1", # ap-northeast-2a
    "subnet-09eaf6fa743d0fc16"  # ap-northeast-2b
  ]
}
variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}
variable "desired_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 0
}

variable "region" {
  default = "ap-northeast-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
