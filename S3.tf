resource "aws_s3_bucket" "s3bucket" {
  bucket_prefix = "${var.aws_resource_name_tag}-"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_public_access_block" "s3bucket" {
  bucket = aws_s3_bucket.s3bucket.id
  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_notification" "s3-trigger" {
    bucket = aws_s3_bucket.s3bucket.id

    lambda_function {
        lambda_function_arn = "${aws_lambda_function.csv_handler.arn}"
        events              = ["s3:ObjectCreated:*"]
        filter_suffix       = ".csv"
    }
    depends_on = [aws_lambda_permission.allow_execution_form_bucket]
}