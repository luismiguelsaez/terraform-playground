locals {
    environment = "testing"
    s3_origin_id = "YXNkZmFzZGZhc2RmCg"
}

provider "aws" {
    region = "us-east-1"
}

resource "random_string" "bucket-name" {
  length           = 12
  special          = false
}

resource "aws_s3_bucket_policy" "statics" {
  bucket = aws_s3_bucket.statics.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "main"
    Statement = [
      {
        Sid       = "CloudfrontAllow"
        Effect    = "Allow"
        Principal = {
            "AWS" = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.statics.id}"
        }
        Action    = "s3:GetObject"
        Resource = ["${aws_s3_bucket.statics.arn}/*"]
      },
    ]
  })
}

resource "aws_s3_bucket" "statics" {
  bucket = format("%s-%s", local.environment, lower(random_string.bucket-name.result))
  acl    = "private"

  tags = {
    Name        = format("%s-%s", local.environment, lower(random_string.bucket-name.result))
    Environment = local.environment
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = format("%s-%s", local.environment, lower(random_string.bucket-name.result))
  key    = "index.html"
  source = "content/index.html"
  etag = filemd5("content/index.html")
}

resource "aws_cloudfront_origin_access_identity" "statics" {
  comment = "Origin identity for S3 bucket access"
}

resource "aws_cloudfront_distribution" "statics" {
  origin {
    domain_name = aws_s3_bucket.statics.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = format("origin-access-identity/cloudfront/%s", aws_cloudfront_origin_access_identity.statics.id)
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_cloudfront_origin_access_identity.statics.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["SP","ES"]
    }
  }

  tags = {
    Name        = format("%s-%s", local.environment, lower(random_string.bucket-name.result))
    Environment = local.environment
  }
}
