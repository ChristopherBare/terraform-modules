# S3 Website

example usage:
```terraform
# main.tf (Main Configuration)

provider "aws" {
  region = "us-east-1"
}

module "website" {
  source                  = "./path/to/your/module"
  website_bucket_name     = "my-website-bucket"
  index_document          = "index.html"
  error_document          = "error.html"
  origin_id               = "website-origin"
}

output "website_url" {
  description = "URL for accessing the website"
  value       = module.website.website_url
}
```