############################################
# S3 BUCKET (PRIVATE) + PUBLIC ACCESS BLOCK
############################################
resource "aws_s3_bucket" "website_bucket" {
  bucket        = var.website_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.website_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#############################
# CLOUDFRONT ORIGIN ACCESS CONTROL (OAC)
#############################
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.website_bucket_name}-oac"
  description                       = "OAC for private S3 origin ${var.website_bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

############################################
# CLOUDFRONT DISTRIBUTION (USES OAC + S3 ORIGIN)
############################################
resource "aws_cloudfront_distribution" "website_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.index_document

  # IMPORTANT: use the S3 *REST* endpoint for private bucket access
  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = var.origin_id

    # With OAC, keep s3_origin_config (no OAI required)
    s3_origin_config {}

    # Attach the OAC created above
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = var.origin_id
    viewer_protocol_policy = "redirect-to-https"

    # You can migrate to cache_policy_id/origin_request_policy_id later.
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
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

############################################
# S3 BUCKET POLICY — ALLOW CLOUDFRONT VIA OAC
############################################
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid = "AllowCloudFrontReadViaOAC"
    actions = [
      "s3:GetObject"
    ]
    # Grant only on objects, not the bucket root
    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    # Limit access to only your distribution using OAC
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.website_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json

  # Ensure the bucket exists before we attach the policy
  depends_on = [
    aws_s3_bucket_public_access_block.this
  ]
}