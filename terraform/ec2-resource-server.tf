

# resource "aws_instance" "resource_server" {
#   ami                         = "ami-0c233408b5af0e974" # Docker 설치된 최신 Amazon Linux 2 ECS AMI
#   instance_type               = "t3.medium"
#   subnet_id                   = "subnet-03b2c1c9e27320a03" # NAT 프록시와 동일 서브넷
#   vpc_security_group_ids      = [aws_security_group.resource_sg.id]
#   key_name                    = "origemiteKEY"
#   associate_public_ip_address = false # NAT 프록시 통해 인터넷 통신
#   private_ip                  = "10.0.14.109"
#   tags = {
#     Name = "resource-server"
#   }
# }

locals {
  compose_b64 = base64encode(file("${path.module}/../docker/resource/docker-compose.yml"))
  prom_b64    = base64encode(file("${path.module}/../docker/resource/prometheus.yml"))
  fluent_b64  = base64encode(file("${path.module}/../docker/resource/fluent-bit.conf"))
  otel_b64 = base64encode(file("${path.module}/../docker/resource/otel-collector-config.yaml"))

}



resource "aws_instance" "resource_server" {
  ami                         = "ami-0c233408b5af0e974"
  instance_type               = "t3.medium"
  subnet_id                   = "subnet-03906d593e24a05b1" # NAT 프록시와 동일 서브넷
  vpc_security_group_ids      = [aws_security_group.resource_sg.id]
  key_name                    = "origemiteKEY"
  private_ip                  = "10.0.128.109"
  associate_public_ip_address = false # NAT 프록시 통해 인터넷 통신

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  # cloud-init
user_data_replace_on_change = true
user_data = <<-EOF
#!/bin/bash
set -eux
systemctl stop ecs || true
systemctl disable ecs || true
systemctl enable --now docker || true
usermod -aG docker ec2-user || true

# docker compose v2 설치(플러그인)
mkdir -p /usr/local/lib/docker/cli-plugins
if ! /usr/bin/docker compose version >/dev/null 2>&1; then
  curl -fsSL "https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/lib/docker/cli-plugins/docker-compose
  chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
fi

mkdir -p /opt/resource-stack
cd /opt/resource-stack
echo "${local.compose_b64}" | base64 -d > docker-compose.yml
echo "${local.prom_b64}"    | base64 -d > prometheus.yml
echo "${local.fluent_b64}"  | base64 -d > fluent-bit.conf
echo "${local.otel_b64}" | base64 -d > otel-collector-config.yaml


cat > .env.resource <<'ENVEOF'
MYSQL_ROOT_PASSWORD=change-me-root
MYSQL_DATABASE=app
MYSQL_USER=app
MYSQL_PASSWORD=change-me-app
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=change-me-grafana
ES_JAVA_HEAP_MB=512
ENVEOF
echo "KAFKA_ADVERTISED_HOST=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)" >> .env.resource

/usr/bin/docker compose --env-file .env.resource up -d

cat >/etc/systemd/system/resource-stack.service <<'UNIT'
[Unit]
Description=Resource Stack (docker compose)
After=docker.service
Requires=docker.service
[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/resource-stack
ExecStart=/usr/bin/docker compose --env-file ./.env.resource up -d
ExecStop=/usr/bin/docker compose down
[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable resource-stack
EOF

  tags = { Name = "resource-server" }
}

output "resource_server_private_ip" {
  value = aws_instance.resource_server.private_ip
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
    cidr_blocks = ["0.0.0.0/0"] # 원하는 경우 본인 IP로 제한 가능
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
  # Fluent Bit (수집 포트)
  ingress {
    description = "Fluent Bit"
    from_port   = 24224
    to_port     = 24224
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "Fluent Bit UDP"
    from_port   = 24224
    to_port     = 24224
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # OpenTelemetry Collector (OTLP)
  ingress {
    description = "OTLP gRPC"
    from_port   = 4317
    to_port     = 4317
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "OTLP HTTP"
    from_port   = 4318
    to_port     = 4318
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # Zipkin
  ingress {
    description = "Zipkin"
    from_port   = 9411
    to_port     = 9411
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # Vault
  ingress {
    description = "Vault"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }


  # 기본 아웃바운드 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
