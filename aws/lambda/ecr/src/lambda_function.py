import boto3

def lambda_handler(event, context):

  ecr = boto3.client("ecr")

  print(str(event))

  response = ecr.create_repository(
    repositoryName=event["detail"]["repository-name"],
    tags=[
      {
        'Key':'auto-create',
        'Value':'true'
      }
    ],
    imageScanningConfiguration={
      'scanOnPush': True
    },
    encryptionConfiguration={
      'encryptionType': 'AES256'
    }
  )

  return { 
      'message' : str(response)
  }

if __name__ == "__main__":
  lambda_handler("{}","{}")
