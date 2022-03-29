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
  # echo zip hello.js
  cd lambda/
  
  rm --force hello.zip 2>&1
  zip hello.zip hello.js  > /dev/null 2>&1
  # echo aws lambda update-function-code $PROJECT_NAME

  local VERSION=$(aws lambda publish-version \
    --function-name $PROJECT_NAME \
    --description $1 \
    --region $AWS_REGION \
    --query Version \
    --output text)

   echo "$VERSION"
}


createAlias(){
  VERSION=$2
  echo "version $VERSION "
  echo aws lambda create-alias $1
  aws lambda create-alias \
      --function-name $PROJECT_NAME \
      --name $1 \
      --function-version $VERSION \
      --region $AWS_REGION  
}

addPermission(){
  ENVIRONMENT=$1
  ACCOUNT_ID=$2
  API_GATEWAY_ID=$3
  aws lambda add-permission \
    --function-name "arn:aws:lambda:$AWS_REGION:$ACCOUNT_ID:function:$PROJECT_NAME:$1" \
    --source-arn "arn:aws:execute-api:$AWS_REGION:$ACCOUNT_ID:$API_GATEWAY_ID/*/GET/hello" \
    --principal apigateway.amazonaws.com \
    --statement-id "AllowAPIGatewayInvoke" \
    --action lambda:InvokeFunction

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
  deleteAlias $1
fi


if [[ $1 == 'prod' ]] && [[ $2 == 'updateFnLambda' ]]; then
  geteval=$(updateFunctionLambda $1)
  echo $geteval
fi


if [[ $1 == 'prod' ]] && [[ $2 == 'createAlias' ]]; then
  createAlias $1 $3
fi

if [[ $1 == 'prod' ]] && [[ $2 == 'addPermission' ]]; then
  addPermission $1 $3 $4
fi

