#!/bin/bash


AWS_PROFILE=default
AWS_REGION=us-east-1

PROJECT_NAME=lisandro.colocho


dir="$(cd "$(dirname "$0")"; pwd)"

cd $dir

create-env(){

    # local key=$(aws iam create-access-key \
    #     --user-name $PROJECT_NAME \
    #     --query 'AccessKey.{AccessKeyId:AccessKeyId,SecretAccessKey:SecretAccessKey}' \
    #     --profile $AWS_PROFILE \
    #     2>/dev/null)
    
}