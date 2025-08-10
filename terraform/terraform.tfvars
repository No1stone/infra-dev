# terraform.tfvars
aws_region           = "ap-northeast-2"
vpc_id               = "vpc-00fae3f8256a9cd22"
private_subnet_ids   = ["subnet-03906d593e24a05b1","subnet-007794ab3532b2b5c"]
public_subnet_ids    = ["subnet-03b2c1c9e27320a03"]
nat_instance_id      = "i-0cb725da6d6fa54fe"
node_subnet_ids    = ["subnet-03906d593e24a05b1"]
cluster_name         = "spring-eks-dev"
cluster_version      = "1.30"
instance_types       = ["t3.medium"]
node_min             = 1
node_desired         = 1
node_max             = 3
node_disk            = 20
