########################
# IAM for EKS/Nodes
########################
data "aws_iam_policy_document" "eks_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  assume_role_policy = data.aws_iam_policy_document.eks_trust.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "node_ssm" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


data "aws_iam_policy_document" "node_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  assume_role_policy = data.aws_iam_policy_document.node_trust.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

#############
# EKS
#############
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = local.cluster_subnet_ids   # 기존 프라이빗 서브넷
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = var.tags

#   lifecycle {
#     prevent_destroy = true
#   }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy]
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = local.effective_node_subnet_ids

  scaling_config {
    min_size     = var.node_min
    desired_size = var.node_desired
    max_size     = var.node_max
  }

  labels = {
    "node-role" = "gateway"
  }

  instance_types = var.instance_types
  disk_size      = var.node_disk

  update_config {
    max_unavailable = 1
  }

  tags = {
      Name = "eks-node-default"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr
  ]
}


resource "aws_eks_node_group" "app" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng-app"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = local.effective_node_subnet_ids

  scaling_config {
    min_size     = var.node_min
    desired_size = var.node_desired
    max_size     = var.node_max
  }

  labels = {
    "node-role" = "app"
  }

  instance_types = var.instance_types
  disk_size      = var.node_disk

  update_config {
    max_unavailable = 1
  }

  tags = {
      Name = "eks-node-app"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr
  ]
}
