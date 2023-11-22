resource "aws_s3_bucket" "website_bucket" {
  bucket        = var.website_bucket_name
  force_destroy = true
}

resource "aws_cloudfront_distribution" "website_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.index_document

  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = var.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = var.origin_id
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
    use_origin_access_identity = false
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.website_bucket.arn]
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
  roles      = [aws_iam_role.cloudfront_role.id]
}

resource "aws_iam_role" "cloudfront_role" {
  name = "cloudfront_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "cloudfront.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_role_policy" {
  role       = aws_iam_role.cloudfront_role.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}
