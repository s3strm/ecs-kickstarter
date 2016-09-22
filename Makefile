STACK_NAME = ecs-kickstarter
AWS_DEFAULT_REGION = us-west-1
LAMBDA_BUCKET = an_s3_bucket
LAMBDA_PREFIX = path_in_s3_bucket_to_lambda.zip
LAMBDA_MD5 ?= $(shell find ./lambda -iname \*.py -print0 | xargs -0 cat | md5)
LAMBDA_ZIP = lambda-$(CODE_MD5).zip
LAMBDA_KEY = $(LAMBDA_PREFIX)/$(LAMBDA_ZIP)

ACTION ?= $(shell ../bin/cloudformation_action $(STACK_NAME))
TEMPLATE = ./cfn.json

PARAMETERS  = "ParameterKey=MovieBucketName,ParameterValue=$(MOVIE_BUCKET)"
PARAMETERS += "ParameterKey=CodeBucket,ParameterValue=$(GENERAL_BUCKET)"
PARAMETERS += "ParameterKey=CodeKey,ParameterValue=$(CODE_KEY)"

.PHONY: stack upload_lambda clean

stack: upload_lambda
	aws cloudformation $(ACTION)-stack    \
	  --stack-name "$(STACK_NAME)"        \
	  --template-body "file://$(TEMPLATE)"       \
	  --parameters $(PARAMETERS)          \
	  --capabilities CAPABILITY_IAM       \
	  2>&1
	@aws cloudformation wait stack-$(ACTION)-complete \
	  --stack-name $(STACK_NAME)

upload_lambda: lambda.zip
	@aws s3 cp lambda.zip s3://$(LAMBDA_BUCKET)/$(LAMBDA_KEY)

lambda/settings.py:
	@rm -f ./lambda/settings.py
	@echo 'region = "$(AWS_DEFAULT_REGION)"' >> ./lambda/settings.py

lambda.zip: clean lambda/settings.py
	cd ./lambda && \
	  zip -9rq ../lambda.zip $(shell find .)

clean:
	@rm -f ./lambda/settings.py ./lambda.zip
