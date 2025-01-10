resource "aws_sns_topic" "sns_topic" {
  name = "my-sns-topic"
}

resource "null_resource" "build_dotnet_lambda" {
  provisioner "local-exec" {
    command     = <<EOT
      dotnet restore ../DocumentUpload/DocumentUpload.csproj
      dotnet publish ../DocumentUpload/DocumentUpload.csproj -c Release -r linux-x64 --self-contained false -o ../DocumentUpload/publish
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "../DocumentUpload/publish/"
  output_path = "./eda_app.zip"
  depends_on  = [null_resource.build_dotnet_lambda]
}

resource "aws_lambda_function" "eda_app" {
  filename         = "eda_app.zip"
  function_name    = "eda_app"
  role             = aws_iam_role.eda_role.arn
  handler          = "DocumentUpload"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "dotnet8"
  depends_on       = [data.archive_file.lambda]
  memory_size = 512
  environment {
    variables = {
      ASPNETCORE_ENVIRONMENT = "Production"
    }
  }
}

resource "aws_lambda_function_url" "eda_app_url" {
  function_name      = aws_lambda_function.eda_app.function_name
  authorization_type = "NONE"
}

resource "aws_cloudwatch_log_group" "eda_app_logs" {
  name              = "/aws/lambda/eda_app"
  retention_in_days = 7
}

resource "aws_s3_bucket" "eda_storage_bucket" {
  bucket = "eda-storage-bucket"
}

output "eda_url" {
  value = aws_lambda_function_url.eda_app_url.function_url
}