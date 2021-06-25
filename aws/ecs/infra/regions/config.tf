terraform {
  required_version = "=1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.46.0"
    }
  }
  # We should define a remote backend ( S3 ), but I'm not going to do it for this test
}

provider "aws" {
  region = "eu-west-1"
  assume_role {
    # This is a role I have to use to have privileges in the AWS account I'm using for testing
    role_arn = "arn:aws:iam::393788435358:role/DelegatedAdministrator"
  }
}

# Different AWS providers for each region, to be used in the module call
provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
  assume_role {
    # This is a role I have to use to have privileges in the AWS account I'm using for testing
    role_arn = "arn:aws:iam::393788435358:role/DelegatedAdministrator"
  }
}

provider "aws" {
  alias  = "nvirginia"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::393788435358:role/DelegatedAdministrator"
  }
}
