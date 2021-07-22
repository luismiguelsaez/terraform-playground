import json
import os
import glob

def lambda_handler(event, context):
    print(glob.glob(os.environ.get('FS_PATH')))
    return {}