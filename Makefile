STACK_NAME = ecs-kickstarter
AWS_DEFAULT_REGION = us-west-1
LAMBDA_BUCKET = an_s3_bucket
LAMBDA_PREFIX = path_in_s3_bucket_to_lambda.zip
LAMBDA_MD5 ?= $(shell find ./lambda -iname \*.py -print0 | xargs -0 cat | md5)
LAMBDA_ZIP = lambda-$(CODE_MD5).zip
LAMBDA_KEY = $(LAMBDA_PREFIX)/$(LAMBDA_ZIP)
LAMBDA_ROLE_ARN = arn::blah
ECS_TASK = my_task
ECS_ENVIRONMENT_VARIABLES = my_task

.PHONY: stack upload_lambda clean

stack: upload_lambda parameters.txt
	$(eval ACTION ?= $(shell ../bin/cloudformation_action $(STACK_NAME)))
	aws cloudformation $(ACTION)-stack           \
	  --stack-name "$(STACK_NAME)"               \
	  --template-body "file://./cfn.json"        \
	  --parameters "file://./parameters.txt"     \
	  --capabilities CAPABILITY_IAM              \
	  2>&1
	@aws cloudformation wait stack-$(ACTION)-complete \
	  --stack-name $(STACK_NAME)

upload_lambda: lambda.zip
	@aws s3 cp lambda.zip s3://$(LAMBDA_BUCKET)/$(LAMBDA_KEY)

clean:
	@rm -f parameters.txt ./lambda/settings.py ./lambda.zip

parameters.txt:
	$(eval PARAM_STR := 'ParameterKey=%s,ParameterValue=%s ')
	printf $(PARAM_STR) "Task" $(ECS_TASK) >> parameters.txt
	printf $(PARAM_STR) "LambdaBucket" $(LAMBDA_BUCKET) >> parameters.txt
	printf $(PARAM_STR) "LambdaKey" $(LAMBDA_KEY) >> parameters.txt
	printf $(PARAM_STR) "LambdaRoleArn" $(LAMBDA_ROLE) >> parameters.txt

lambda/settings.py:
	@rm -f ./lambda/settings.py
	@echo 'region = "$(AWS_DEFAULT_REGION)"' >> ./lambda/settings.py

lambda.zip: clean lambda/settings.py
	$(eval FILE_LIST := $(shell cd ./lambda/ && find . -type f))
	@cd ./lambda && zip -9rq ../lambda.zip $(FILE_LIST)

