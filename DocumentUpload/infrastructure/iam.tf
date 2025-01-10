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

resource "aws_iam_role" "eda_role" {
  name               = "eda_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "sns_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "sns:*"
    ]

    resources = [
      "${aws_sns_topic.sns_topic.arn}",
    ]
  }
}

resource "aws_iam_policy" "sns_policy" {
  name        = "sns_policy"
  path        = "/"
  policy      = data.aws_iam_policy_document.sns_policy_document.json
}

resource "aws_iam_role_policy_attachment" "sns_policy_attachment" {
  role       = aws_iam_role.eda_role.name
  policy_arn = aws_iam_policy.sns_policy.arn
}

data "aws_iam_policy_document" "s3_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::eda-storage-bucket/*",
      "arn:aws:s3:::eda-storage-bucket",
    ]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name        = "s3_policy"
  path        = "/"
  policy      = data.aws_iam_policy_document.s3_policy_document.json
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.eda_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

data "aws_iam_policy_document" "log_policy_document" {
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

resource "aws_iam_policy" "log_policy" {
  name        = "log_policy"
  path        = "/"
  policy      = data.aws_iam_policy_document.log_policy_document.json
}

resource "aws_iam_role_policy_attachment" "log_policy_attachment" {
  role       = aws_iam_role.eda_role.name
  policy_arn = aws_iam_policy.log_policy.arn
}