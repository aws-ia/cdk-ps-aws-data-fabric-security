#!/bin/bash -e

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

echo "Starting Functional Tests"

# Setup Deployment Guide
DOCS_BRANCH="html-guide"
## Check if docs/ files are modified?
git fetch
git branch
DIFF_OUTPUT=$(git diff HEAD..origin/main)
## If docs are modified, render updated index.html file and
## create a PR with index.html file.
if echo "${DIFF_OUTPUT}" | grep "^diff --git a/docs/"; then
    printf '\nChanges detected in the /docs files. \n'
    #--- Github pages site generation ---#
    asciidoctor --version
    # Generate guide - filename -> index.html
    asciidoctor --base-dir docs/ --backend=html5 -o ../index.html -w --doctype=book -a toc2 -a production_build docs/boilerplate/index_deployment_guide.adoc
    ## Create PR with index.html file
    CURRENT_BRANCH=$(git branch --show-current)
    git checkout main
    git checkout -b "${DOCS_BRANCH}"
    git add index.html
    git commit -m '(automated) rendered html deployment guide'
    git push --set-upstream origin "${DOCS_BRANCH}"
    gh pr create --title 'Generated deployment guide' --body "_This is an automated PR with rendered html file for the deployment guide. Please review it before merge_"
else
    printf '\nNo changes detected in the /docs files. \n'
fi

cd ${PROJECT_PATH}

## Add CDK Deployment Steps here:
## Install AWS CDK
npm install -g aws-cdk

## Install Python Requirements if Python project. Install NPM packages if Node based.
 if [ -f ${PROJECT_PATH}/requirements.txt ];
   then
     echo "Installing python requirements"
     python -m pip install -r requirements.txt
 elif [ -f ${PROJECT_PATH}/package.json ];
     then
       echo 'Starting CDK-NAG Checks'
       cp ${PROJECT_PATH}/package.json ${PROJECT_PATH}/package.json.org
       echo "Install Packages"
       npm install --legacy-peer-deps
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
  mv cdk.json cdk.json.org
  echo "$overrides" > cdk.json
fi
set -e
##----------------------------------------------------

# Pull in dev.yml config or similar
secret_name=$(cat ${BASE_PATH}/task_metadata.json |  jq '.project | .DEVCONFIG_OVERRIDE_NAME')
secret_region=$(cat ${BASE_PATH}/task_metadata.json |  jq '.project | .DEVCONFIG_OVERRIDE_REGION')
set +e
overrides=$(aws secretsmanager get-secret-value --secret-id $secret_name --query SecretString --output text --region $secret_region)
# convert the JSON string to YAML and save it to a file
if [ "$?" -eq 0 ]; then
  mv ${PROJECT_PATH}/config/dev.yaml ${PROJECT_PATH}/config/dev.yaml.org
  echo "$overrides" > ${PROJECT_PATH}/config/dev.yaml
fi
set -e

# Detect and launch scripts
if [ -f ${PROJECT_PATH}/*-install.sh ]; then
  ## Deploy Project
  ./dfs-solution-install.sh
else
  ## Deploy Project
  npx cdk deploy --verbose --all --require-approval never --no-notices
fi

if [ -f ${PROJECT_PATH}/*-uninstall.sh ]; then
  ./dfs-solution-uninstall.sh
else
  ## Tear down the Stack
  npx cdk destroy --verbose --all --force --profile default --no-notices
fi

## Cleanup from E2E
## Cleaning up Dev config file
if [ -f ${PROJECT_PATH}/config/dev.yaml]; then
  rm -f ${PROJECT_PATH}/config/dev.yaml
  mv ${PROJECT_PATH}/config/dev.yaml.org ${PROJECT_PATH}/config/dev.yaml
fi
## Cleaning up package.json
if [ -f ${PROJECT_PATH}/package.json ];
  then
    rm -rf node_modules && rm -f package-lock.json
    mv ${PROJECT_PATH}/package.json.org ${PROJECT_PATH}/package.json
    exit 0
else
  exit 0
fi