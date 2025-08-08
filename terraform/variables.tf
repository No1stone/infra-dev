variable "cluster_name" {
  description = "EKS Cluster name"
  default     = "spring-eks-dev"
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
