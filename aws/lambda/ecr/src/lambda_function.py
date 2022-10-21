import boto3
import json

def lambda_handler(event, context):

  error = False
  message = ""

  ecr = boto3.client("ecr")

  print(str(event))

  if event["detail"]["errorCode"] == "RepositoryNotFoundException":
    try:
      response = ecr.create_repository(
        repositoryName=event["detail"]["requestParameters"]["repositoryName"],
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
    except boto3.RepositoryAlreadyExistsException as repoException:
      error = True
      message = "Repository [%s] already exists".format(repositoryName=event["detail"]["requestParameters"]["repositoryName"])
    except Exception as exception:
      error = True
      message = "Error while creating repository [%s]: %s".format(repositoryName=event["detail"]["requestParameters"]["repositoryName"])

  if error:
    return {
      'message': message
    }
  else:
    return {
      'message': "Repository [%s] created".format(repositoryName=event["detail"]["requestParameters"]["repositoryName"])
    }



if __name__ == "__main__":
  with open('event.json') as user_file:
    json_event_contents = user_file.read()
  lambda_handler(json_event_contents,"{}")
