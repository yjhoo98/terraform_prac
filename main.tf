provider "aws" {
  region = "ap-northeast-2"
}

# 전체 웹/애플리케이션 인프라
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Web tier security group"

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Application tier security group"

  ingress {
    description     = "App traffic from web tier"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Database tier security group"

  ingress {
    description     = "MySQL from app tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
}

# EC2 인스턴스 생성
resource "aws_instance" "web_server" {
  count = 2

  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name = "${var.project_name}-web-${count.index}"
    Tier = "Web"
  }
}

