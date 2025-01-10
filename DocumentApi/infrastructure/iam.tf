data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eda_api_role" {
  name               = "eda_api_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "api_log_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "api_log_policy" {
  name   = "api_log_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.api_log_policy_document.json
}

resource "aws_iam_role_policy_attachment" "api_log_policy_attachment" {
  role       = aws_iam_role.eda_api_role.name
  policy_arn = aws_iam_policy.api_log_policy.arn
}

data "aws_iam_policy_document" "api_dynamo_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:*",
    ]
    resources = [
      module.dynamodb_table.dynamodb_table_arn
    ]
  }
}

resource "aws_iam_policy" "api_dynamo_policy" {
  name   = "api_dynamo_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.api_dynamo_policy_document.json
}

resource "aws_iam_role_policy_attachment" "api_dynamo_policy_attachment" {
  role       = aws_iam_role.eda_api_role.name
  policy_arn = aws_iam_policy.api_dynamo_policy.arn
}
