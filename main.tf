# main.tf
provider "aws" {
  region = "ap-northeast-2"
}
resource "aws_security_group" "load_balancer" {
  name        = "load-balancer-sg"
  description = "Allow web traffic to load balancer"

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 로드 밸런서 -> 웹 서버 통신 허용
  egress {
    description     = "To web servers"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server.id]
  }
}

# 웹 서버 보안 그룹
resource "aws_security_group" "web_server" {
  name        = "web-server-sg"
  description = "Allow web traffic to web servers"
  vpc_id      = null # 기본 VPC 사용

  # HTTP 허용 (포트 80)
  ingress {
    description = "HTTP from load balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }

  # HTTPS 허용 (포트 443)
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH 허용 (관리자용, 제한적 IP)
  ingress {
    description = "SSH from office"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["121.171.237.78/32"]
  }
  egress {
   description = "Allow all outbound"
   from_port = 0
   to_port = 0
   protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
   Name = "web-server-sg"
   Type = "Web"
 }
}


# 애플리케이션 서버 보안 그룹
resource "aws_security_group" "app_server" {
  name        = "app-server-sg"
  description = "Allow traffic from web to app servers"

  # 웹 서버로부터의 HTTP/HTTPS
  ingress {
    description     = "HTTP from web servers"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server.id] # 다른 SG 참조
  }
}

# 데이터베이스 보안 그룹
resource "aws_security_group" "database" {
  name        = "database-sg"
  description = "Allow traffic from app to database"

  # 애플리케이션 서버로부터의 MySQL
  ingress {
    description     = "MySQL from app servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_server.id]
  }

  # VPC 내부만 허용 (더 제한적)
  ingress {
    description = "MySQL from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # VPC CIDR
  }
}



# 동적 ingress 규칙 생성
resource "aws_security_group" "dynamic_sg" {
  name        = "dynamic-sg-${var.environment}"
  description = "Dynamically created security group"

  # SSH는 사무실 IP만 허용
  ingress {
    description = "SSH from office"
    from_port   = var.ports["ssh"].from_port
    to_port     = var.ports["ssh"].to_port
    protocol    = var.ports["ssh"].protocol
    cidr_blocks = var.office_ips
  }

  # HTTP/HTTPS는 모든 IP 허용
  dynamic "ingress" {
    for_each = { for k, v in var.ports : k => v if k != "ssh" }

    content {
      description = "${ingress.key} from anywhere"
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = var.allowed_ips
    }
  }
}


# EC2 인스턴스 생성
resource "aws_instance" "web_server" {
  ami           = "ami-0c9c942bd7bf113a2"  # Ubuntu 22.04
  instance_type = "t2.micro"

  # Security Group 적용 방법1: 직접 지정
  vpc_security_group_ids = [
    aws_security_group.web_server.id,
   # aws_security_group.ssh_access.id        # 여러 SG 적용 가능
  ]

  tags = {
    Name = "web-server-${var.environment}"
  }
}

# EC2 인스턴스에 user_data 추가 (웹 서버 설치)
resource "aws_instance" "web_with_userdata" {
  ami           = "ami-0c9c942bd7bf113a2"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web_server.id]

  # 웹 서버 자동 설치
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Welcome to ${var.environment} environment</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "web-with-nginx"
  }
}

resource "aws_security_group" "admin_access" {
  name        = "admin-access-sg"
  description = "Restricted admin access"

  ingress {
    description = "SSH from VPN"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["121.171.237.78/32"]
  }

  ingress {
    description = "RDP from specific IPs"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["121.171.237.78/32"]
  }
}
