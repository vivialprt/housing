#!/bin/bash
aws sso login --profile $AWS_PROFILE

export AWS_REGION=$(aws configure get region --profile $AWS_PROFILE)
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile $AWS_PROFILE --query Account --output text)
export ECR_LOGIN_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"