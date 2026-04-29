output "api_endpoint" {
  description = "Public HTTP API base URL. Append /items to hit the Lambda."
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "lambda_function_name" {
  description = "Name of the deployed Lambda function."
  value       = aws_lambda_function.api.function_name
}

output "lambda_function_arn" {
  description = "ARN of the deployed Lambda function."
  value       = aws_lambda_function.api.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB items table."
  value       = aws_dynamodb_table.items.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB items table."
  value       = aws_dynamodb_table.items.arn
}

output "cloudwatch_log_group_lambda" {
  description = "CloudWatch Log Group for Lambda invocations."
  value       = aws_cloudwatch_log_group.lambda.name
}

output "cloudwatch_log_group_api" {
  description = "CloudWatch Log Group for API Gateway access logs."
  value       = aws_cloudwatch_log_group.api.name
}
