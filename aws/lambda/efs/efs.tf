resource "aws_lambda_function" "example" {
  #filename         = "lambda_function.zip"
  #source_code_hash = filebase64sha256("lambda_function.zip")
  s3_bucket = format("application-%s", random_string.bucket.result)
  s3_key    = "application/lambda_function.zip"

  function_name = "lambda-efs"
  role          = aws_iam_role.this.arn
  handler       = "lambda_function.lambda_handler"

  runtime = "python3.8"

  environment {
    variables = {
      FS_PATH = "/mnt/efs"
    }
  }

  file_system_config {
    arn              = aws_efs_access_point.this.arn
    local_mount_path = "/mnt/efs"
  }

  vpc_config {
    subnet_ids         = [aws_subnet.this.id]
    security_group_ids = [aws_security_group.lambda_nfs.id]
  }

  depends_on = [aws_efs_mount_target.this, aws_s3_bucket_object.function]
}

resource "aws_efs_file_system" "this" {
  creation_token = "lambda-efs"
  encrypted      = true
}

resource "aws_efs_mount_target" "this" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = aws_subnet.this.id
  security_groups = [aws_security_group.lambda_nfs.id]
}

resource "aws_efs_access_point" "this" {
  file_system_id = aws_efs_file_system.this.id
  root_directory {
    path = "/efs"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 0777
    }
  }
  posix_user {
    gid = 1000
    uid = 1000
  }
}
