output "alb_arn" {
  value       = aws_lb.app_alb.arn
  description = "The ARN of the Application Load Balancer"
}

output "alb_dns_name" {
  value       = aws_lb.app_alb.dns_name
  description = "The DNS name of the Application Load Balancer"
}

output "security_group_id" {
  value       = aws_security_group.alb_sg.id
  description = "The ID of the security group attached to the ALB"
}

output "target_group_arn" {
  value       = aws_lb_target_group.app_tg.arn
  description = "The ARN of the target group used with the ALB"
}

output "db_endpoint" {
  value = aws_db_instance.db.endpoint
}

output "db_username" {
  value = aws_db_instance.db.username
}

output "db_password_ssm" {
  value = aws_ssm_parameter.db_password.name
}

output "db_name" {
  value = aws_db_instance.db.identifier
}

output "db_id" {
  value = aws_db_instance.db.id
}

output "efs_file_system_id" {
  value = aws_efs_file_system.app_efs.id
}

output "website_url" {
  value = "https://www.${var.domain_name}"
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "route53_name_servers" {
  value = aws_route53_zone.main.name_servers
}
