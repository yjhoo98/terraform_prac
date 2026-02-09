# outputs.tf 파일

# 인스턴스 ID 출력
output "instance_id" {
  description = "생성된 EC2 인스턴스의 ID"
  value       = aws_instance.training_instance.id
}

# 퍼블릭 IP 출력
output "public_ip" {
  description = "EC2 인스턴스의 퍼블릭 IP 주소"
  value       = aws_instance.training_instance.public_ip
}



# 인스턴스 상태 출력
output "instance_state" {
  description = "EC2 인스턴스의 현재 상태"
  value       = aws_instance.training_instance.instance_state
}

# SSH 접속 명령어 출력
output "ssh_command" {
  description = "인스턴스에 SSH로 접속하는 명령어"
  value = var.key_name != null ? (
    "ssh -i ./${var.key_name}.pem ubuntu@${aws_instance.training_instance.public_ip}"
  ) : (
    "키 페어가 설정되지 않았습니다"
  )
}

