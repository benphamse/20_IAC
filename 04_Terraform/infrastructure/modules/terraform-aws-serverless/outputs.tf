output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.main.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.main.function_name
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.main.invoke_arn
}

output "lambda_function_version" {
  description = "Latest published version of Lambda function"
  value       = aws_lambda_function.main.version
}

output "lambda_function_qualified_arn" {
  description = "Qualified ARN of the Lambda function"
  value       = aws_lambda_function.main.qualified_arn
}

output "lambda_log_group_arn" {
  description = "ARN of the Lambda CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.arn
}

output "lambda_log_group_name" {
  description = "Name of the Lambda CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "api_gateway_rest_api_id" {
  description = "ID of the API Gateway REST API"
  value       = var.create_api_gateway ? aws_api_gateway_rest_api.main[0].id : null
}

output "api_gateway_rest_api_arn" {
  description = "ARN of the API Gateway REST API"
  value       = var.create_api_gateway ? aws_api_gateway_rest_api.main[0].arn : null
}

output "api_gateway_rest_api_execution_arn" {
  description = "Execution ARN of the API Gateway REST API"
  value       = var.create_api_gateway ? aws_api_gateway_rest_api.main[0].execution_arn : null
}

output "api_gateway_deployment_id" {
  description = "ID of the API Gateway deployment"
  value       = var.create_api_gateway ? aws_api_gateway_deployment.main[0].id : null
}

output "api_gateway_stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = var.create_api_gateway && var.enable_api_logging ? aws_api_gateway_stage.main[0].arn : null
}

output "api_gateway_invoke_url" {
  description = "Invoke URL of the API Gateway"
  value       = var.create_api_gateway ? aws_api_gateway_deployment.main[0].invoke_url : null
}

output "api_gateway_log_group_arn" {
  description = "ARN of the API Gateway CloudWatch log group"
  value       = var.create_api_gateway && var.enable_api_logging ? aws_cloudwatch_log_group.api_gateway_logs[0].arn : null
}

output "api_gateway_log_group_name" {
  description = "Name of the API Gateway CloudWatch log group"
  value       = var.create_api_gateway && var.enable_api_logging ? aws_cloudwatch_log_group.api_gateway_logs[0].name : null
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = var.lambda_schedule_expression != null ? aws_cloudwatch_event_rule.lambda_schedule[0].arn : null
}

output "eventbridge_rule_name" {
  description = "Name of the EventBridge rule"
  value       = var.lambda_schedule_expression != null ? aws_cloudwatch_event_rule.lambda_schedule[0].name : null
}
