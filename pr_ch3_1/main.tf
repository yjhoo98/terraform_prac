resource "aws_instance" "web" {
 count = var.instance_count

 ami = var.ami_id
 instance_type = var.instance_type
 
 tags = {
  Name = "${var.project_name}-${var.environment}-${count.index}"
  Environment = var.environment
  Project = var.project_name
 }
}
