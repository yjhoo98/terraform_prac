variable "project_name" {
 type = string
 description = "projectname"
 default = "terraform-training"
}

variable "environment" {
 type = string
 description = "env"
 default = "dev"
}

variable "instance_count" {
 type = number
 description = "num of instance"
 default = 1
 validation{
  condition = var.instance_count >= 1 && var.instance_count <=5
  error_message = "1~5"
 }
}

variable "instance_type" {
 type = string
 description = "EC2 instance type"
 default = "t3.micro"
}

variable "ami_id" {
 type = string
 description = "Ubuntu 22.04 AMI ID region:seoul"
 default = "ami-0bae2335fbe5a4018"
}

# 환경별 설정 맵
variable "env_configs" {
  type = map(object({
    instance_type = string
    min_size      = number
    max_size      = number
    node_count    = number
  }))

  default = {
    dev = {
      instance_type = "t2.micro"
      min_size      = 1
      max_size      = 2
      node_count    = 1
    }

    staging = {
      instance_type = "t3.small"
      min_size      = 2
      max_size      = 4
      node_count    = 2
    }

    prod = {
      instance_type = "t3.large"
      min_size      = 3
      max_size      = 6
      node_count    = 3
    }
  }

  validation {
    condition     = contains(keys(var.env_configs), var.environment)
    error_message = "환경은 dev, staging, prod 중 하나여야 합니다."
  }
}

