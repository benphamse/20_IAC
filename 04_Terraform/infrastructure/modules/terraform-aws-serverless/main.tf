# Lambda Function
resource "aws_lambda_function" "main" {
  filename         = var.lambda_zip_path
  function_name    = "${var.naming_prefix}-lambda"
  role             = var.lambda_execution_role_arn
  handler          = var.lambda_handler
  source_code_hash = var.lambda_zip_path != null ? filebase64sha256(var.lambda_zip_path) : null
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  # VPC Configuration (optional)
  dynamic "vpc_config" {
    for_each = var.subnet_ids != null ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  # Environment Variables
  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  # Dead Letter Queue
  dynamic "dead_letter_config" {
    for_each = var.dlq_target_arn != null ? [1] : []
    content {
      target_arn = var.dlq_target_arn
    }
  }

  # Tracing
  tracing_config {
    mode = var.enable_xray_tracing ? "Active" : "PassThrough"
  }

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-lambda-function"
  })

  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.naming_prefix}-lambda"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.cloudwatch_kms_key_id

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-lambda-logs"
  })
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "main" {
  count = var.create_api_gateway ? 1 : 0

  name        = "${var.naming_prefix}-api"
  description = "API Gateway for ${var.naming_prefix}"

  endpoint_configuration {
    types = [var.api_gateway_endpoint_type]
  }

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-api-gateway"
  })
}

# API Gateway Resource
resource "aws_api_gateway_resource" "main" {
  count = var.create_api_gateway ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.main[0].id
  parent_id   = aws_api_gateway_rest_api.main[0].root_resource_id
  path_part   = var.api_path_part
}

# API Gateway Method
resource "aws_api_gateway_method" "main" {
  count = var.create_api_gateway ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.main[0].id
  resource_id   = aws_api_gateway_resource.main[0].id
  http_method   = var.api_http_method
  authorization = var.api_authorization

  request_parameters = var.api_request_parameters
}

# API Gateway Integration
resource "aws_api_gateway_integration" "main" {
  count = var.create_api_gateway ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.main[0].id
  resource_id = aws_api_gateway_resource.main[0].id
  http_method = aws_api_gateway_method.main[0].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.main.invoke_arn
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "apigw" {
  count = var.create_api_gateway ? 1 : 0

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main[0].execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "main" {
  count = var.create_api_gateway ? 1 : 0

  depends_on = [
    aws_api_gateway_method.main,
    aws_api_gateway_integration.main,
  ]

  rest_api_id = aws_api_gateway_rest_api.main[0].id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.main[0].id,
      aws_api_gateway_method.main[0].id,
      aws_api_gateway_integration.main[0].id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "main" {
  count = var.create_api_gateway && var.enable_api_logging ? 1 : 0

  deployment_id = aws_api_gateway_deployment.main[0].id
  rest_api_id   = aws_api_gateway_rest_api.main[0].id
  stage_name    = var.api_stage_name

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs[0].arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      caller         = "$context.identity.caller"
      user           = "$context.identity.user"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-api-stage"
  })
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  count = var.create_api_gateway && var.enable_api_logging ? 1 : 0

  name              = "/aws/apigateway/${var.naming_prefix}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.cloudwatch_kms_key_id

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-api-gateway-logs"
  })
}

# EventBridge Rule for scheduled Lambda
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  count = var.lambda_schedule_expression != null ? 1 : 0

  name                = "${var.naming_prefix}-lambda-schedule"
  description         = "Schedule for Lambda function"
  schedule_expression = var.lambda_schedule_expression

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-lambda-schedule"
  })
}

# EventBridge Target
resource "aws_cloudwatch_event_target" "lambda_target" {
  count = var.lambda_schedule_expression != null ? 1 : 0

  rule      = aws_cloudwatch_event_rule.lambda_schedule[0].name
  target_id = "LambdaTarget"
  arn       = aws_lambda_function.main.arn
}

# Lambda Permission for EventBridge
resource "aws_lambda_permission" "eventbridge" {
  count = var.lambda_schedule_expression != null ? 1 : 0

  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule[0].arn
}
