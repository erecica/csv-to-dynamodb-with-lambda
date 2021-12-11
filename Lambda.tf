# Create a zip file of the script. Lambda needs this to create the function
data "archive_file" "lambda_function_archive" {
  type         = "zip"
  source_file  = "${path.module}/script/index.py"
  output_path  = "${path.module}/script/${var.aws_resource_name_tag}.zip"
}
# Create Lambda function. 
resource "aws_lambda_function" "csv_handler" {
  filename      = "${data.archive_file.lambda_function_archive.output_path}"
  function_name = "${var.aws_resource_name_tag}"
  role          = aws_iam_role.iam_resources_role.arn
  handler       = "index.lambda_handler"
  source_code_hash = "${data.archive_file.lambda_function_archive.output_base64sha256}"
  memory_size = 128 # value in MB. You're free to change this. Min 128 MB / Max 10 GB.
  timeout     = 60 # value in seconds. You're free to change this up to 900 sec (15 min)
  runtime = "python3.8"
  # Wait for the .zip file to be created
  depends_on = [data.archive_file.lambda_function_archive] 
  
  environment {
    variables = {
      s3bucket = "${aws_s3_bucket.s3bucket.bucket}",
      DynamoDBTable = "${var.aws_resource_name_tag}"
    }
  }
}
# Allow S3 bucket to Execute the Lambda function. This is needed for the S3 Trigger
resource "aws_lambda_permission" "allow_execution_form_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_handler.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3bucket.arn
}