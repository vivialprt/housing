bucket = "terraform-state-" + yamldecode(file("../secret.yml"))["terraform_state_random_suffix"]
key    = "housing/dev/etl/terraform.tfstate"
region = "eu-central-1"
encrypt = true
dynamodb_table = "terraform-locks-" + yamldecode(file("../secret.yml"))["terraform_state_random_suffix"]