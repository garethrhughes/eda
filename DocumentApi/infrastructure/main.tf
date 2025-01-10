resource "null_resource" "build_nest_lambda" {
  provisioner "local-exec" {
    command     = <<EOT
       npm install ../ && ncc build ../src/serverless.ts -o ../dist
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "../dist/"
  output_path = "./eda_api.zip"
  depends_on  = [null_resource.build_nest_lambda]
}

resource "aws_lambda_function" "eda_api" {
  filename         = "eda_api.zip"
  function_name    = "eda_api"
  role             = aws_iam_role.eda_api_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "nodejs22.x"
  depends_on       = [data.archive_file.lambda]
  memory_size = 512
  environment {
    variables = {
      ASPNETCORE_ENVIRONMENT = "Production"
    }
  }
}

resource "aws_lambda_function_url" "eda_api_url" {
  function_name      = aws_lambda_function.eda_api.function_name
  authorization_type = "NONE"
}

resource "aws_cloudwatch_log_group" "eda_api_logs" {
  name              = "/aws/lambda/eda_api"
  retention_in_days = 7
}

output "eda_url" {
  value = aws_lambda_function_url.eda_api_url.function_url
}

module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "eda-api-table"
  hash_key = "id"
  range_key = "timestamp"

  attributes = [
    {
      name = "id"
      type = "S"
    },
    {
      name = "timestamp"
      type = "N"
    }
  ]
}