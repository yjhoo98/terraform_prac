# main.tf (또는 ami.tf)

# 지역 변수로 AMI 필터 정의
locals {
  ami_filters = {
    ubuntu = [
      {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
      },
      {
        name   = "virtualization-type"
        values = ["hvm"]
      }
    ]

    amazon_linux = [
      {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
      }
    ]

    windows = [
      {
        name   = "name"
        values = ["Windows_Server-2019-English-Full-Base-*"]
      }
    ]
  }

  ami_owners = {
    ubuntu      = ["099720109477"]
    amazon_linux = ["amazon"]
    windows     = ["amazon"]
  }
}

# 데이터 소스 구성
data "aws_ami" "selected_os" {
  most_recent = true

  dynamic "filter" {
    for_each = local.ami_filters[var.os_type]
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }

  owners = local.ami_owners[var.os_type]
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.selected_os.id
  instance_type = "t3.micro"

  tags = {
    OS       = var.os_type
    AMI_Name = data.aws_ami.selected_os.name
  }
}

