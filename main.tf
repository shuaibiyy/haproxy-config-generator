provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

resource "aws_iam_role" "generator_iam" {
  name = "generator_iam"
  assume_role_policy = "${file("policies/lambda-role.json")}"
}

resource "aws_lambda_function" "generator_lambda" {
  filename = "haproxy_config_generator.zip"
  function_name = "haproxy_config_generator"
  role = "${aws_iam_role.generator_iam.arn}"
  handler = "index.handler"
  runtime = "nodejs4.3"
  source_code_hash = "${base64sha256(file("haproxy_config_generator.zip"))}"
}

resource "aws_api_gateway_rest_api" "generator_api" {
  name = "haproxy_config_generator"
  description = "API for HAProxy Configuraation Generator"
  depends_on = ["aws_lambda_function.generator_lambda"]
}

resource "aws_api_gateway_resource" "generator_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.generator_api.id}"
  parent_id = "${aws_api_gateway_rest_api.generator_api.root_resource_id}"
  path_part = "generate"
}

resource "aws_api_gateway_method" "generator_method" {
  rest_api_id = "${aws_api_gateway_rest_api.generator_api.id}"
  resource_id = "${aws_api_gateway_resource.generator_resource.id}"
  http_method = "POST"
  authorization = "NONE"

  request_models = {
    "application/json" = "${aws_api_gateway_model.generator_request_model.name}"
  }
}

resource "aws_api_gateway_integration" "generator_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.generator_api.id}"
  resource_id = "${aws_api_gateway_resource.generator_resource.id}"
  http_method = "${aws_api_gateway_method.generator_method.http_method}"
  type = "AWS"
  integration_http_method = "${aws_api_gateway_method.generator_method.http_method}"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.generator_lambda.arn}/invocations"
}

resource "aws_api_gateway_model" "generator_request_model" {
  rest_api_id = "${aws_api_gateway_rest_api.generator_api.id}"
  name = "Configuration"
  description = "A configuration schema"
  content_type = "application/json"
  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "GeneratorConfiguration",
  "type": "array",
  "properties": {
    "mode": { "type": "string" },
    "name": { "type": "string" },
    "predicate": { "type": "string" },
    "cookie": { "type": "string" },
    "servers": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "name": { "type": "string" },
          "ip": { "type": "string" }
        }
      }
    }
  }
}
EOF
}

resource "aws_api_gateway_model" "generator_response_model" {
  rest_api_id = "${aws_api_gateway_rest_api.generator_api.id}"
  name = "ConfigurationFile"
  description = "A configuration file schema"
  content_type = "application/json"
  schema = <<EOF
{
  "type": "object"
}
EOF
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.generator_api.id}"
  resource_id = "${aws_api_gateway_resource.generator_resource.id}"
  http_method = "${aws_api_gateway_method.generator_method.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "${aws_api_gateway_model.generator_response_model.name}"
  }
}

resource "aws_api_gateway_integration_response" "generator_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.generator_api.id}"
  resource_id = "${aws_api_gateway_resource.generator_resource.id}"
  http_method = "${aws_api_gateway_method.generator_method.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"
  depends_on = ["aws_api_gateway_integration.generator_integration"]
}

resource "aws_api_gateway_deployment" "production" {
  rest_api_id = "${aws_api_gateway_rest_api.generator_api.id}"
  stage_name = "api"
  depends_on = ["aws_api_gateway_integration.generator_integration"]
}
