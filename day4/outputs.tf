# 기본 리소스 정보
output "instance_ids" {
  value       = aws_instance.web[*].id
  description = "생성된 모든 EC2 인스턴스 ID"
}

output "instance_public_ips" {
  value       = aws_instance.web[*].public_ip
  description = "EC2 인스턴스들의 공인 IP 주소"
}

# 사용자 친화적 정보
# 사용자 친화적 정보
output "ssh_commands" {
  value = [
    for instance in aws_instance.web :
    var.key_name != null ? 
      "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${instance.public_ip} # ${instance.tags.Name}" :
      "키 페어가 설정되지 않았습니다. (ssh ubuntu@${instance.public_ip}) # ${instance.tags.Name}"
  ]
  description = "각 인스턴스별 SSH 접속 명령어"
}

output "web_urls" {
  value = [
    for instance in aws_instance.web :
    "http://${instance.public_ip}"
  ]
  description = "웹 서버 접속 URL 목록"
}

# 보안 정보
output "security_group_id" {
  value       = aws_security_group.web.id
  description = "웹 서버 보안 그룹 ID"
}

# 통계 정보
output "infrastructure_summary" {
  value = {
    instance_count  = length(aws_instance.web[*].id)
    security_groups = aws_security_group.web.id
    region          = var.aws_region
    environment     = var.environment
    deployed_at     = timestamp()
  }
  description = "인프라 구성 요약 정보"
}

