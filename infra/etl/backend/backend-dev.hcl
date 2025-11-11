bucket = yamldecode(file("../global_variables.yml"))["terraform_state_bucket"]
key    = "housing/dev/etl/terraform.tfstate"
region = "eu-central-1"
encrypt = true
dynamodb_table = yamldecode(file("../global_variables.yml"))["terraform_state_dynamodb_table"]