output "alb_dns" {
  description = "Application Load Balancer DNS"
  value       = aws_lb.alb.dns_name
}

output "strapi_api_endpoint" {
  value = "http://${aws_lb.alb.dns_name}/api"
}
