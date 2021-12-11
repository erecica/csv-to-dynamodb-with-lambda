# Create a S3 bucket, where the csv file(s) are uploaded
resource "aws_s3_bucket" "s3bucket" {
  bucket_prefix = "${var.aws_resource_name_tag}-"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = false
  }
}
# Block public access control by default
resource "aws_s3_bucket_public_access_block" "s3bucket" {
  bucket = aws_s3_bucket.s3bucket.id
  block_public_acls   = true
  block_public_policy = true
}

# Create Trigger and attach the Lambda function to the trigger. 
# This trigger will be executed when the filter suffix ( in this case .csv file(s) ) is met.
resource "aws_s3_bucket_notification" "s3-trigger" {
    bucket = aws_s3_bucket.s3bucket.id

    lambda_function {
        lambda_function_arn = "${aws_lambda_function.csv_handler.arn}"
        events              = ["s3:ObjectCreated:*"]
        filter_suffix       = ".csv"
    }
    # Be sure to have the correct execution rights before creating the trigger
    depends_on = [aws_lambda_permission.allow_execution_form_bucket]
}