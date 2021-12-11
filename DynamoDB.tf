# Creats a DynamoDB Table with TTL enabled
resource "aws_dynamodb_table" "csv-data-from-s3" {
  name           = "${var.aws_resource_name_tag}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "countUUID"

  attribute {
    name = "countUUID"
    type = "S"
  }
  
  ttl {
    attribute_name = "recordTTL"
    enabled = true # change this to 'false' if you wish to disable Time to Live (TTL)
  }

  tags = {
    Name        = "${var.aws_resource_name_tag}"
  }
}