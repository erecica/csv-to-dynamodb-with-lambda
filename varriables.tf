variable "aws_key" {
  type        = string
  description = "AWS Access Key"
  default   = "" # set your with your AWS Access Key

}

variable "aws_secret" {
  type        = string
  description = "AWS Secret Key"
  default   = "" # set your AWS Secret Key
}

variable "aws_region" {
  type        = string
  description = "AWS region used for all resources"
  default     = "" # change this if you wish to rename your resources

}

variable "aws_resource_name_tag" {
  type        = string
  description = "This prefix is used to tag all resources created by Terraform."
  default     = "csv-to-dynamodb-with-lambda" # change this if you wish to rename your resources
}
