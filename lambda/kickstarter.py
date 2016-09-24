from __future__ import print_function
import ast
import boto3
import json
import settings

def run_task(s3_key):
    client = boto3.client('ecs')

    import pdb; pdb.set_trace()

    response = client.run_task(
        cluster=settings.cluster,
        taskDefinition=settings.task_definition,
        overrides=settings.overrides,
    )

def lambda_handler(event, context):
    for record in event["Records"]:
        for imdb_id in ast.literal_eval(record["Sns"]["Message"])["Records"]:
            s3_key = "s3://something/{}/video.mp4".format(imdb_id)
            run_task(imdb_id)
            print(imdb_id)

    return True

if __name__ == "__main__":
    event = { "Records": [ {"Sns": { "Message": "{\"Records\": [\"tt0427312\"]}"} } ] }
    print(json.dumps(lambda_handler(event, None)))
