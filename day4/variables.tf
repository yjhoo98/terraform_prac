# variables.tf

# 운영체제 타입
variable "os_type" {
  description = "운영체제 타입"
  type        = string
  default     = "ubuntu"

  validation {
    condition     = contains(["ubuntu", "amazon_linux", "windows"], var.os_type)
    error_message = "OS 타입은 ubuntu, amazon_linux, windows 중 하나여야 합니다."
  }
}

