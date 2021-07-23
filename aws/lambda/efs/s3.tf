resource "random_string" "bucket" {
  length  = 16
  special = false
  number  = true
  lower   = true
  upper   = false
}

resource "aws_s3_bucket" "application" {
  bucket = format("application-%s", random_string.bucket.result)
  acl    = "private"
}

resource "aws_s3_bucket_object" "function" {
  bucket = format("application-%s", random_string.bucket.result)
  key    = "application/lambda_function.py"
  source = "code/lambda_function.py"
  etag   = filemd5("code/lambda_function.py")
}
