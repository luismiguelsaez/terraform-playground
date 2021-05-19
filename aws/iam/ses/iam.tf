provider "aws" {
  region = "eu-west-1"
}

### Data

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "current" {
  name = "staging"
}

### Variables

variable "ses_identity_arn" {
  type = string
  default = "arn:aws:ses:eu-west-1:355231963939:identity/empathy.co"
}

variable "k8s_namespace" {
  type = string
  default = "playboard"
}

variable "k8s_serviceaccount" {
  type = string
  default = "play-user-api"
}

### Resources

resource "aws_iam_policy" "ses_sendmail" {
  name = "play-user-api-ses-sendmail"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Effect   = "Allow"
        Resource = var.ses_identity_arn
      },
    ]
  })
}

resource "aws_iam_role" "play_user_api" {
  name = "play-user-api"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${trimprefix(data.aws_eks_cluster.current.identity[0].oidc[0].issuer,"https://")}"
        }
        Condition = {
          StringEquals = {
            "${trimprefix(data.aws_eks_cluster.current.identity[0].oidc[0].issuer,"https://")}:sub" = "system:serviceaccount:${var.k8s_namespace}:${var.k8s_serviceaccount}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "play_user_api_ses" {
  role       = aws_iam_role.play_user_api.name
  policy_arn = aws_iam_policy.ses_sendmail.arn
}

