# Provider
provider "aws" {
  alias = "regional"
}

# DynamoDB Table
resource "aws_dynamodb_table" "greeting_logs" {
  provider       = var.region_provider
  name           = "GreetingLogs"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  provider = var.region_provider
  name = "lambda-role-${var.region_provider.region}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  provider = var.region_provider
  role     = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda: Greeter
resource "aws_lambda_function" "greeter" {
  provider = var.region_provider
  function_name = "greeter-${var.region_provider.region}"
  handler = "handler.handler"
  runtime = "python3.10"
  role = aws_iam_role.lambda_role.arn
  filename = "../../lambdas/greeter/lambda.zip"
  environment {
    variables = {
      TABLE = aws_dynamodb_table.greeting_logs.name
      EMAIL = var.email
      REPO  = var.github_repo
    }
  }
}

# Lambda: Dispatcher
resource "aws_lambda_function" "dispatcher" {
  provider = var.region_provider
  function_name = "dispatcher-${var.region_provider.region}"
  handler = "handler.handler"
  runtime = "python3.10"
  role = aws_iam_role.lambda_role.arn
  filename = "../../lambdas/dispatcher/lambda.zip"
  environment {
    variables = {
      EMAIL = var.email
      REPO  = var.github_repo
    }
  }
}

# API Gateway (HTTP API)
resource "aws_apigatewayv2_api" "api" {
  provider = var.region_provider
  name = "regional-api-${var.region_provider.region}"
  protocol_type = "HTTP"
}

# API Routes
resource "aws_apigatewayv2_integration" "greeter_integration" {
  provider = var.region_provider
  api_id = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.greeter.arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "dispatcher_integration" {
  provider = var.region_provider
  api_id = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.dispatcher.arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "greet_route" {
  provider = var.region_provider
  api_id = aws_apigatewayv2_api.api.id
  route_key = "POST /greet"
  target = "integrations/${aws_apigatewayv2_integration.greeter_integration.id}"
}

resource "aws_apigatewayv2_route" "dispatch_route" {
  provider = var.region_provider
  api_id = aws_apigatewayv2_api.api.id
  route_key = "POST /dispatch"
  target = "integrations/${aws_apigatewayv2_integration.dispatcher_integration.id}"
}