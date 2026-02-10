# variables.tf

variable "environment" {
  description = "배포 환경"
  type        = string
  default     = "dev"
}

variable "allowed_ips" {
  description = "허용할 IP CIDR 목록"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "office_ips" {
  description = "사무실 IP 범위"
  type        = list(string)
  default     = ["121.171.237.78/32"]
}

variable "ports" {
  description = "개방할 포트 목록"
  type = map(object({
    protocol  = string
    from_port = number
    to_port   = number
  }))

  default = {
    ssh = {
      protocol  = "tcp"
      from_port = 22
      to_port   = 22
    }

    http = {
      protocol  = "tcp"
      from_port = 80
      to_port   = 80
    }

    https = {
      protocol  = "tcp"
      from_port = 443
      to_port   = 443
    }
  }

}
variable "project_name" {
  description = "Allow traffic from web to app servers"
  type        = string
  default     = "server-sg"
}

variable "ami_id" {
  description = "EC2에 사용할 AMI ID"
  type        = string
  default     = "ami-0c9c942bd7bf113a2" # Ubuntu 22.04
}

variable "instance_type" {
  description = "EC2 인스턴스 유형"
  type        = string
  default     = "t3.micro"
}

# outputs.tf에서 var.key_name 쓰고 있으면 필요
variable "key_name" {
  description = "EC2 키페어 이름 (pem 파일명)"
  type        = string
  default     = "your-key-name"
}

