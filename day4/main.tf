terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# AWS Provider 설정
provider "aws" {
  # 환경 변수 AWS_DEFAULT_REGION 자동 사용
  # access_key, secret_key도 환경 변수에서 자동으로 읽어옵니다.
  
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Course      = "Terraform-3Day"
      Environment = var.environment
    }
  }
}

# 보안 그룹 (이름 변경: web)
resource "aws_security_group" "web" {
  name        = "allow_web_traffic"
  description = "Allow SSH and HTTP inbound traffic"

  # SSH
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (웹 서버용)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_traffic"
  }
}

# EC2 인스턴스 (이름 변경: web, 다중 생성: count)
resource "aws_instance" "web" {
  count = var.instance_count # 변수에서 개수 제어

  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  vpc_security_group_ids = [aws_security_group.web.id]

  # 태그에 인덱스(순서) 번호 부여
  tags = {
    Name = "${var.instance_name}-${count.index + 1}"
    Type = "Web"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    delete_on_termination = true
  }

  # 웹 서버(Nginx) 설치 예시
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              echo "Web Server ${count.index + 1}" > /var/www/html/index.html
              EOF
}
