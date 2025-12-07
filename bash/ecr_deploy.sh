#!/bin/bash

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_LOGIN_URL

docker push $REPO_URL