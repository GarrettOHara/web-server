output "instance_id" {
  value       = aws_instance.app_server.id
  description = "The instance id"
  sensitive   = false
}

output "public_ipv4_addr" {
  value       = aws_instance.app_server.public_ip
  description = "The instance id"
  sensitive   = false
}

output "sg_name" {
  value       = aws_security_group.allow_web_traffic.name
  description = "The web security group id"
  sensitive   = false
}

