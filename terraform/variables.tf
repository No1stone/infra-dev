# AWS
variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}


# 기존 네트워크 관리/참조
variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
  description = "EKS cluster subnets (>=2 AZ)"
}

variable "public_subnet_ids" {
  type    = list(string)
  default = []
}

variable "nat_instance_id" {
  type = string
  description = "Existing NAT/Proxy EC2 instance id"
}

variable "nat_eip_allocation_id" {
  type    = string
  default = null
}

# EKS
variable "cluster_name" {
  type    = string
  default = "spring-eks-dev"
}

variable "cluster_version" {
  type    = string
  default = "1.30"
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_min" {
  type    = number
  default = 1
}

variable "node_subnet_ids" {
  type        = list(string)
  default     = []
  description = "EKS nodegroup subnets (default: first of private_subnet_ids)"
}

variable "node_desired" {
  type    = number
  default = 2
}

variable "node_max" {
  type    = number
  default = 3
}

variable "node_disk" {
  type    = number
  default = 20
}

# 공통 태그
variable "tags" {
  type = map(string)
  default = {
    Project = "spring-portfolio"
    Owner   = "wonseok"
    Env     = "dev"
  }
}
