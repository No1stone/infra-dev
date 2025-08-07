resource "aws_instance" "resource_server" {
  ami                         = "ami-0c233408b5af0e974" # Docker 설치된 최신 Amazon Linux 2 ECS AMI
  instance_type               = "t3.medium"
  subnet_id                   = "subnet-03b2c1c9e27320a03" # NAT 프록시와 동일 서브넷
  vpc_security_group_ids      = [aws_security_group.resource_sg.id]
  key_name                    = "origemiteKEY"
  associate_public_ip_address = false # NAT 프록시 통해 인터넷 통신
  private_ip                  = "10.0.14.109"
  tags = {
    Name = "resource-server"
  }
}

resource "aws_security_group" "resource_sg" {
  name        = "resource-sg"
  description = "Allow only necessary ports for services"
  vpc_id      = "vpc-00fae3f8256a9cd22"

  # SSH (from anywhere or restrict to your IP)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 원하는 경우 본인 IP로 제한 가능
  }

  # Redis
  ingress {
    description = "Redis"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # Kafka
  ingress {
    description = "Kafka"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # Zookeeper (Kafka용)
  ingress {
    description = "Zookeeper"
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # Grafana
  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # Prometheus
  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # Elasticsearch
  ingress {
    description = "Elasticsearch"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # Kibana
  ingress {
    description = "Kibana"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/16"] # 내부 VPC 대역에서만 접속 허용
  }
  # 기본 아웃바운드 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
