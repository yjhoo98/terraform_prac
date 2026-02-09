# outputs.tf 파일에 정의
output "instance_id" {
  value       = aws_instance.demo.id
  description = "생성된 EC2 인스턴스 ID"
}

output "public_ip" {
  value       = aws_instance.demo.public_ip
  description = "인스턴스의 퍼블릭 IP 주소"
}

output "private_ip" {
  value       = aws_instance.demo.private_ip
  description = "인스턴스의 프라이빗 IP 주소"
  sensitive   = true # 민감한 정보로 표시
}

