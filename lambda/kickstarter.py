from __future__ import print_function
import ast
import boto3
import json
import settings

def run_task(s3_key):
    client = boto3.client('ecs')
    response = client.run_task(
        cluster=settings.cluster,
        taskDefinition=settings.task_definition,
        overrides={ "containerOverrides": [
            {
                "name": settings.container_name,
                "environment": [{
                    "name": "KEY",
                    "value": s3_key,
                }]
            }
        ]}
    )
    print(response)

def lambda_handler(event, context):
    for record in event["Records"]:
        for r in ast.literal_eval(record["Sns"]["Message"])["Records"]:
            key = r["s3"]["object"]["key"]
            bucket = r["s3"]["bucket"]["name"]
            s3_key = "s3://{}/{}".format(bucket, key)
            run_task(s3_key)

    return True

if __name__ == "__main__":
    event = { "Records": [ {"Sns": { "Message": "{\"Records\": [\"tt0427312\"]}"} } ] }
    print(json.dumps(lambda_handler(event, None)))
