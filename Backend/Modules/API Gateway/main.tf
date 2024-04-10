resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.api_name
  put_rest_api_mode = "overwrite"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "count" {
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "count"
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

#--------------------------------- OPTIONS Method -----------------------------------#

resource "aws_api_gateway_method" "OPTIONS" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS Method Response
resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method = aws_api_gateway_method.OPTIONS.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "OPTIONS" {
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  resource_id          = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method          = aws_api_gateway_method.OPTIONS.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

# OPTIONS Integration Method Response
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method = aws_api_gateway_method.OPTIONS.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method.OPTIONS
  ]
}

#--------------------------------- GET Method ---------------------------------#
resource "aws_api_gateway_method" "GET" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.count.id
  http_method   = "GET"
  authorization = "NONE"
}

# GET Method Integration Response
resource "aws_api_gateway_integration" "GET" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.count.id
  http_method             = "GET"
  type                    = "AWS_PROXY"   # Proxy Request sends the lambda function response completely without mapping.
  integration_http_method = "POST"  # Makes Post request to the given lambda function.
  uri                     = aws_lambda_function.count.invoke_arn  # ARN of the lambda function.
}

# GET Method Response
resource "aws_api_gateway_method_response" "get_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.count.id
  http_method = aws_api_gateway_method.GET.http_method
  status_code = "200"

  # Response from lambda function attached with CORS header will be sent as response to the client.
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}