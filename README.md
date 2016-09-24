# s3strm/ecs-kickstarter

Trigger an ECS task to run from an SNS event.


## Pipeline

something -> SNS -> Lambda -> ECS Task


## Usage

It's designed to be used as a submodule and hooked into with a Makefile.


```ShellSession
$ git submodule add blah/s3strm/ecs-kickstarter
```

Then write this Makefile to `./Makefile`
```Makefile

export STACK_NAME = my-stack-name
export AWS_DEFAULT_REGION = us-west-1
export LAMBDA_BUCKET = my-lambda-code-bucket

export ECS_CLUSTER = my_cluster
export ECS_CONTAINER_NAME = my_container
export ECS_TASK_DEFINITION = my_task
export ECS_ENV_OVERRIDES = [{ "name": "SOMETHING", "value": "VALUE" }]

deploy:
    make -e -C ecs-kickstarter stack
```

Then deploy with `make deploy`
