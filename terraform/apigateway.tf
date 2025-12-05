# API Gateway HTTP API para probar conectividad con ALB
# Este API Gateway actúa como proxy hacia el ALB sin autenticación

# VPC Link para conectar API Gateway con ALB en VPC privada
resource "aws_apigatewayv2_vpc_link" "alb_vpc_link" {
  name               = "${var.env}-alb-vpc-link"
  security_group_ids = [aws_security_group.alb_sg.id]
  subnet_ids         = values(aws_subnet.private)[*].id

  tags = {
    Name = "${var.env}-ALB-VPC-Link"
  }
}

# HTTP API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.env}-http-api"
  protocol_type = "HTTP"
  description   = "HTTP API Gateway para probar conectividad con ALB"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["*"]
    max_age       = 300
  }

  tags = {
    Name = "${var.env}-HTTP-API"
  }
}

# Integration con ALB
resource "aws_apigatewayv2_integration" "alb_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = aws_lb_listener.http.arn
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.alb_vpc_link.id

  payload_format_version = "1.0"
  timeout_milliseconds   = 30000

  description = "Proxy all requests to ALB"
}

# Route por defecto - captura todas las peticiones
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}

# Route específica para GET /
resource "aws_apigatewayv2_route" "get_root" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}

# Route específica para GET /health (health check)
resource "aws_apigatewayv2_route" "get_health" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}

# Route para capturar cualquier path
resource "aws_apigatewayv2_route" "any_path" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}

# Stage por defecto (auto-deploy)
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format = jsonencode({
      requestId        = "$context.requestId"
      ip               = "$context.identity.sourceIp"
      requestTime      = "$context.requestTime"
      httpMethod       = "$context.httpMethod"
      routeKey         = "$context.routeKey"
      status           = "$context.status"
      protocol         = "$context.protocol"
      responseLength   = "$context.responseLength"
      integrationError = "$context.integrationErrorMessage"
    })
  }

  default_route_settings {
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }

  tags = {
    Name = "${var.env}-API-Default-Stage"
  }
}

# CloudWatch Log Group para API Gateway
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/${var.env}-http-api"
  retention_in_days = 7

  tags = {
    Name = "${var.env}-API-Gateway-Logs"
  }
}

# Outputs para facilitar el testing
output "api_gateway_endpoint" {
  value       = aws_apigatewayv2_api.http_api.api_endpoint
  description = "URL del API Gateway para probar la conectividad con ALB"
}

output "api_gateway_id" {
  value       = aws_apigatewayv2_api.http_api.id
  description = "ID del API Gateway"
}

output "vpc_link_id" {
  value       = aws_apigatewayv2_vpc_link.alb_vpc_link.id
  description = "ID del VPC Link"
}
