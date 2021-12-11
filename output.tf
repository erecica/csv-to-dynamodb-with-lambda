output "AWS_Region" {
  description = "AWS Region"
  value       = var.aws_region
}

output "AWS_S3bucket" {
  description = "AWS S3 Bucket name created"
  value       = aws_s3_bucket.s3bucket.bucket
}

output "AWS_DynamoDB_Table" {
  description = "AWS DynamoDB table created"
  value       = aws_dynamodb_table.csv-data-from-s3.name
}