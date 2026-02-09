# 테라폼 버전 및 Provider 설정
terraform {
  required_version = ">=1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"     # 4.x 버전 사용
    }
  }
}

# AWS Provider 설정
provider "aws" {
  region = "ap-northeast-2"  # 서울 리전

  # 기본 태그 (모든 리소스에 적용)
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Course      = "Terraform-3Day"
      Environment = "Training"
    }
  }
}

# 보안 그룹 생성
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_training"
  description = "Allow SSH inbound traffic"

  # 인바운드 규칙 (들어오는 트래픽)
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP 허용 (실제 운영에서는 제한 필요)
  }

  # 아웃바운드 규칙 (나가는 트래픽)
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # 모든 프로토콜
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_training"
  }
}

# EC2 인스턴스 생성
resource "aws_instance" "training_instance" {
  # 필수 인수
  ami           = var.ami_id
  instance_type = var.instance_type

  # 네트워크 설정
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  # 키 페어 설정 (있으면 사용)
  key_name = var.key_name

  # 인스턴스 태그
  tags = {
    Name = var.instance_name
    Type = "Training"
  }

  # 루트 볼륨 설정
  root_block_device {
    volume_size           = 20  # GB
    volume_type           = "gp3"
    delete_on_termination = true  # 인스턴스 삭제시 볼륨도 삭제
  }

  # 연결 시 사용자 데이터 (선택 사항)
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello from Terraform Training!" > /tmp/hello.txt
  EOF
}

