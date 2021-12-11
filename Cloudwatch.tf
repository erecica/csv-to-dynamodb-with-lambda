resource "aws_cloudwatch_log_group" "loggroup" {
  name              = "/aws/lambda/${aws_lambda_function.csv_handler.function_name}"
  retention_in_days = 7
  depends_on = [
    aws_lambda_function.csv_handler
  ]
}