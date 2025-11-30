#!/bin/bash

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_LOGIN_URL

docker push $JOB_REPO_URL