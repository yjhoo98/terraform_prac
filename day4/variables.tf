# 인스턴스 이름 변수
variable "instance_name" {
  description = "EC2 인스턴스 이름"
  type        = string
  default     = "TerraformTrainingInstance"
}

# 인스턴스 타입 변수
variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition     = can(regex("^t[23]\\.", var.instance_type))
    error_message = "인스턴스 타입은 t2 또는 t3 계열이어야 합니다."
  }
}

# AMI ID 변수 (Ubuntu 22.04 LTS)
variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID"
  type        = string
  default     = "ami-0c9c942bd7bf113a2"  # 서울 리전용
  
  # 다른 리전용 AMI (참고용)
  # us-east-1: ami-0c55b159cbfafe1f0
  # ap-northeast-1: ami-0abcdef1234567890
}

# SSH 키 페어 변수
variable "key_name" {
  description = "기존 EC2 키 페어 이름"
  type        = string
  default     = null  # 키 없이 생성
}

# 인스턴스 개수
variable "instance_count" {
  description = "생성할 EC2 인스턴스 개수"
  type        = number
  default     = 2
}

# AWS 리전 (Output 및 Provider에서 사용)
variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

# 환경 이름 (Output 및 Tags에서 사용)
variable "environment" {
  description = "배포 환경 (dev, stage, prod)"
  type        = string
  default     = "Training"
}
