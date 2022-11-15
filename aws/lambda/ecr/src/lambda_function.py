import boto3
import logging
from sys import stdout

def lambda_handler(event, context):

    logger = logging.getLogger("custom")
    h_stdout = logging.StreamHandler(stdout)
    f_stdout = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
    h_stdout.setFormatter(f_stdout)
    logger.addHandler(h_stdout)
    logger.setLevel(logging.DEBUG)

    try:
        session = boto3.Session()
        client_ecr = session.client("ecr")
    except Exception as e:
        logger.error("Error while creating session: {}".format(e))
        return { 'message' : "Error while creating session: {}".format(e) }

    logger.debug("Event: {}".format(str(event)))

    if event["detail"]["errorCode"] == "RepositoryNotFoundException":
        try:
            ecr_response = client_ecr.describe_repositories()
            repo_name = event["detail"]["requestParameters"]["repositoryName"]

            if len(list(filter(lambda x: x['repositoryName'] == repo_name, ecr_response['repositories']))) == 0:
                response = client_ecr.create_repository(
                    repositoryName=repo_name,
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
                logger.debug(f"ECR API response: {response}")
                logger.info(f"Repository [{repo_name}] successfully created")
                return { 'message': f"Repository [{repo_name}] successfully created" }
            else:
                logger.info(f"Repository [{repo_name}] already exists")
                return { 'message': f"Repository [{repo_name}] already exists" }
        except Exception as exception:
            logger.error(f"Error while creating repository: {exception}")
            return { 'message' : "Error while creating repository [{}]: {}".format(repo_name,exception) }



if __name__ == "__main__":
    with open('event.json') as user_file:
        json_event_contents = user_file.read()
    lambda_handler(json_event_contents,"{}")
