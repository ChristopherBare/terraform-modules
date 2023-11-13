# Lambda API

example usage:

```terraform
# main.tf

provider "aws" {
  region = "us-east-1"
}

module "lambda_api" {
  source = "./path/to/your/module"

  api_gateway_name              = "MyApiGateway"
  lambda_function_name          = "MyLambdaFunction"
  lambda_handler                = "index.handler"
  lambda_runtime                = "nodejs14.x"
  lambda_filename               = "./path/to/your/lambda/package.zip"
  lambda_role_name              = "MyLambdaRole"
  lambda_environment_variables  = { KEY1 = "VALUE1", KEY2 = "VALUE2" }
  api_gateway_stage_name        = "dev"
}
```