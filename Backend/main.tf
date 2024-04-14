module "DynamoDB" {
  source = "./Modules/DynamoDB Table"
  hash_key = var.hash_key
  table_name = var.table_name
}

module "Lambda" {
  source = "./Modules/Lambda Function"
  api_gateway_execution_arn = module.API-Gateway.api_gateway_execution_arn
  dynamodb_table_arn = module.DynamoDB.dynamodb_table_arn
}

module "API-Gateway" {
  source = "./Modules/API Gateway"
  api_name = var.api_name
  lambda_invoke_arn = module.Lambda.lambda_invoke_arn
}