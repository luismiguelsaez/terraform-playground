import json
from os import environ

# import requests


def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Test message",
            "az": environ.get('AWS_REGION')
        }),
    }
