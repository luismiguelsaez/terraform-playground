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

resource "aws_acm_certificate" "alias" {
  count = length(var.cloudfront_distribution_aliases)

  domain_name       = var.cloudfront_distribution_aliases[count.index]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = local.environment
  }
}

resource "aws_cloudfront_distribution" "statics" {

  aliases = var.cloudfront_distribution_aliases

  origin {
    domain_name = aws_s3_bucket.statics.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.statics.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

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
    #acm_certificate_arn = ""
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["ES"]
    }
  }

  tags = {
    Name        = format("%s-%s", local.environment, lower(random_string.bucket-name.result))
    Environment = local.environment
  }
}


output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.statics.domain_name
}

output "cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.statics.hosted_zone_id
}