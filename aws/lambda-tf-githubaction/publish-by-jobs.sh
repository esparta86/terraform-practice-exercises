#!/bin/bash
AWS_REGION=us-east-1
# project name
PROJECT_NAME=lambda-tf-githubaction

retrieveAccount(){
# root account id
    local ACCOUNT_ID=$(aws sts get-caller-identity \
        --query Account \
        --output text)
    echo  "$ACCOUNT_ID"
}

retrieve_ApiGateway(){
    local API_GATEWAY_ID=$(aws apigateway get-rest-apis \
        --query "items[?name=='$PROJECT_NAME'].id" \
        --region $AWS_REGION \
        --output text)
    echo "$API_GATEWAY_ID"
}



deleteAlias(){
  echo aws lambda deleteAlias $1
  aws lambda delete-alias \
    --function-name $PROJECT_NAME \
    --name $1 \
    --region $AWS_REGION \
    2>/dev/null

}


updateFunctionLambda(){
  echo zip hello.js
  cd lambda/
  ls -l 
  rm --force hello.zip
  zip hello.zip hello.js
  echo aws lambda update-function-code $PROJECT_NAME

  local VERSION=$(aws lambda publish-version \
    --function-name $PROJECT_NAME \
    --description $1 \
    --region $AWS_REGION \
    --query Version \
    --output text)

   echo "$VERSION"
}

testParameter()
{

  echo "$1"

 
}



dir="$(cd "$(dirname "$0")"; pwd)"

cd "$dir"


[[ $1 != 'prod' && $1 != 'dev' ]] && { echo 'usage: publish.sh <prod | dev>'; exit 1; } ;


if [[ $1 == 'prod' ]] && [[ $2 == 'account' ]]; then
  getval=$(retrieveAccount)
  echo $getval
fi


if [[ $1 == 'prod' ]] && [[ $2 == 'apigateway' ]]; then
  getval=$(retrieve_ApiGateway)
  echo $getval
fi


if [[ $1 == 'prod' ]] && [[ $2 == 'deleteAlias' ]]; then
  deleteAlias
fi


if [[ $1 == 'prod' ]] && [[ $2 == 'updateFnLambda' ]]; then
  geteval=$(updateFunctionLambda $1)
  echo $geteval
fi




