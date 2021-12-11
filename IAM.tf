data "aws_caller_identity" "aws_current_account_id" {}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "aws_resources_inline_policy" {

  statement {
    sid       = "1"
    actions   = ["logs:CreateLogStream","logs:PutLogEvents",]
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.aws_current_account_id.account_id}:log-group:/aws/lambda/${var.aws_resource_name_tag}:*"]
  }

  statement {
    sid       = "2"
    actions   = ["s3:GetObject","s3:DeleteObject"]
    resources = ["${aws_s3_bucket.s3bucket.arn}/*"]
  }

  statement {
    sid       = "3"
    actions   = ["dynamodb:PutItem"]
    resources = ["arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.aws_current_account_id.account_id}:table/${var.aws_resource_name_tag}"]
  }
}

resource "aws_iam_role" "iam_resources_role" {
  name = "${var.aws_resource_name_tag}-iam_role_for_resources"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  inline_policy {
    name   = "${var.aws_resource_name_tag}-inline_policy-for_iam_for_resources"
    policy = data.aws_iam_policy_document.aws_resources_inline_policy.json
  }

}



