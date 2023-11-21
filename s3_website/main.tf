resource "aws_s3_bucket" "website_bucket" {
  bucket        = var.website_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.bucket

  index_document { suffix = var.index_document }
  error_document { key = var.error_document }
}

resource "aws_cloudfront_distribution" "website_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.index_document

  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = var.origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website_access_identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = var.origin_id
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_identity" "website_access_identity" {
  comment = "Access identity for the website S3 bucket"
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = [aws_s3_bucket.website_bucket.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.website_access_identity.iam_arn]
    }

    condition {
      test     = "StringLike"
      variable = "aws:UserAgent"

      values = ["*CloudFront*"]
    }
  }
}

resource "aws_iam_policy" "s3_bucket_policy" {
  name        = "CloudFrontS3BucketPolicy"
  description = "Policy to grant CloudFront access to S3 bucket"

  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_iam_policy_attachment" "bucket_policy_attachment" {
  name       = "s3_bucket_policy_attachment"
  policy_arn = aws_iam_policy.s3_bucket_policy.arn
  roles = [aws_iam_role.cloudfront_role.id]
}

resource "aws_iam_role" "cloudfront_role" {
  name = "cloudfront_role"  # Replace with a meaningful role name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "cloudfront.amazonaws.com"  # CloudFront service principal
      },
      Action    = "sts:AssumeRole"
    }]
  })
}
