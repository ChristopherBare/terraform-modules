# variables.tf

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "website_bucket_name" {
  description = "Name for the S3 bucket used for the website"
}

variable "index_document" {
  description = "The name of the index document (e.g., index.html)"
  default     = "index.html"
}

variable "error_document" {
  description = "The name of the error document (e.g., error.html)"
  default     = "error.html"
}

variable "origin_id" {
  description = "A unique identifier for the CloudFront origin"
  default     = "website-origin"
}
