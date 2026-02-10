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
