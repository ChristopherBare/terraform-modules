# variables.tf

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "api_gateway_name" {
  description = "Name for API Gateway"
}

variable "lambda_function_name" {
  description = "Name for Lambda function"
}

variable "lambda_handler" {
  description = "Lambda function handler"
}

variable "lambda_runtime" {
  description = "Lambda function runtime"
}

variable "lambda_filename" {
  description = "Path to the Lambda function deployment package"
}

variable "lambda_role_name" {
  description = "Name for Lambda IAM role"
}

variable "lambda_environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
}

variable "api_gateway_stage_name" {
  description = "Name for API Gateway deployment stage"
}
