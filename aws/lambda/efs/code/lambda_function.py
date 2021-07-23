import json
import os

def lambda_handler(event, context):
    EFS_DIR = os.environ.get('FS_PATH')

    f = open(EFS_DIR + "/test.txt", "a")
    f.write("Testing file content")
    f.close()
    
    c = 0
    for x in os.listdir('.'):
        c += 1

    return {"dir":EFS_DIR,"files":str(c)}
