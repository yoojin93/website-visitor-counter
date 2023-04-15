resource "aws_api_gateway_rest_api" "cloudresume-api" {
  name = "cloudresume-api"
  description = "Proxy to handle requests to Dynamodb"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "visitor-count" {
  rest_api_id = aws_api_gateway_rest_api.cloudresume-api.id
  parent_id   = aws_api_gateway_rest_api.cloudresume-api.root_resource_id
  path_part   = "visitor_count"
}

# OPTIONS HTTP method.
resource "aws_api_gateway_method" "options" {
  rest_api_id      = aws_api_gateway_rest_api.cloudresume-api.id
  resource_id      = aws_api_gateway_resource.visitor-count.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

# OPTIONS method response.
resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.cloudresume-api.id
  resource_id = aws_api_gateway_resource.visitor-count.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# OPTIONS integration.
resource "aws_api_gateway_integration" "options" {
  rest_api_id          = aws_api_gateway_rest_api.cloudresume-api.id
  resource_id          = aws_api_gateway_resource.visitor-count.id
  http_method          = aws_api_gateway_method.options.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }
}

# OPTIONS integration response.
resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.cloudresume-api.id
  resource_id = aws_api_gateway_resource.visitor-count.id
  http_method = aws_api_gateway_integration.options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_deployment" "cloudresume-api" {
  rest_api_id = aws_api_gateway_rest_api.cloudresume-api.id
  stage_name  = "prod"
}
