provider "aws" {
  region = "eu-central-1"
}

data "aws_caller_identity" "current" {}
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


locals {
  account_id = data.aws_caller_identity.current.account_id
  subnet_ids = data.aws_subnets.default.ids
}