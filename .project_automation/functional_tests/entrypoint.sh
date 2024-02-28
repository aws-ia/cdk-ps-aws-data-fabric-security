#!/bin/bash -e

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

echo "Starting Functional Tests"

cd ${PROJECT_PATH}

## Add CDK Deployment Steps here:
## Install AWS CDK
npm install -g aws-cdk

## Install Python Requirements if Python project
 if [ -f ${PROJECT_PATH}/requirements.txt ];
   then
     echo "Installing python requirements"
     python -m pip install -r requirements.txt
 elif [ -f ${PROJECT_PATH}/package.json ];
     then
       echo 'Starting CDK-NAG Checks'
       cp ${PROJECT_PATH}/package.json ${PROJECT_PATH}/package.json.org
       echo "Install Packages"
       npm install
          if  npm ls | grep cdk-nag >> /dev/null; then
          	echo  "CDK-NAG Present"
          else
            echo  "Please add cdk-nag test your project as described here https://github.com/aws/aws-cdk"
            exit 1
          fi
 fi

echo  'Finished CDK-NAG Checks'

## Fix Typescript issues
npm uninstall -g typescript
npm uninstall typescript
npm install -g typescript
npm install typescript --save-dev


##----------------------------------------------------
## Download cdk.json overrides from AWS Secrets Manager
## ---------------------------------------------------
## Create a 'secret' of type plaintext in AWS Secrets Manager
## and add cdk.json override file contents to it.
## Provide secret name to 'secret_name' parameter below with in your projects metadata and
## the AWS region where you secret is stored to 'aws_region'.

# set defaults
secret_name=$(cat ${BASE_PATH}/task_metadata.json |  jq '.project | .OVERRIDE_NAME')
secret_region=$(cat ${BASE_PATH}/task_metadata.json |  jq '.project | .OVERRIDE_REGION')
# If overrides secret exists, retrieve the secret value as a JSON string
set +e
overrides=$(aws secretsmanager get-secret-value --secret-id $secret_name --query SecretString --output text --region $secret_region)
# convert the JSON string to YAML and save it to a file
if [ "$?" -eq 0 ]; then
  cp cdk.json cdk.json.org
  echo "$overrides" > cdk.json
fi
set -e
##----------------------------------------------------



## Deploy Project
#export CDK_DEFAULT_ACCOUNT=169121843828
npx cdk deploy --verbose --all --require-approval never --no-notices


## Tear down the Stack
npx cdk destroy --verbose --all --force --profile default --no-notices

## Cleanup from E2E
if [ -f ${PROJECT_PATH}/package.json ];
  then
    rm -rf node_modules && rm -f package-lock.json
    mv ${PROJECT_PATH}/package.json.org ${PROJECT_PATH}/package.json
    exit 0
else
  exit 0
fi