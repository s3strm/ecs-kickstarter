from __future__ import print_function
import ast
import boto3
import json
import settings

def lambda_handler(event, context):
    for record in event["Records"]:
        for y in ast.literal_eval(record["Sns"]["Message"])["Records"]:
            print(imdb_id)

    return True
