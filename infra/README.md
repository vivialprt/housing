# Terraform Infra

Resources in AWS cloud.

## Architecture

[Infra Diagram](./infra.drawio)

## Setup

1. Create AWS_PROFILE env var
    - `export AWS_PROFILE={your_profile}`
2. Login to AWS (I am using SSO)
3. Generate some number for terraform state bucket
4. Create `secrets.yml` from `secrets.yml.example`
5. Put generated number to `terraform_state_bucket` value
6. Create `dev.tfvars` and `prod.tfvars` from `example.tfvars` in `./{component}/envs/`
7. Generate unique postfixes for dev and prod buckets 
    > all dev buckets are going to have one postfix and all prod buckets are going to have one postfix, but dev and prod postixes can (and should) be different
8. Replace vars in `dev.tfvars` and `prod.tfvars` with correct values
9. Create TFSTATE_BUCKET env var and put there `terraform_state_bucket` value from `secrets.yml`
10. Init terraform (assuming in `infra/{component}`)
    - `terraform init -backend-config=envs/backend-{env}.hcl -backend-config="bucket=$TFSTATE_BUCKET"`
    > To switch between states use same command with `-reconfigure` flag

## ETL

ETL uses ECS task definitions scheduled with EventBridge. Task definitions use ECR repos (docker images). To add task, add `ecs_task_module` to `./etl/ecs.tf`. You'll have to provide:
- task name
- task cron schedule
- task env vars
- all the rest can be copied from `aruodas_vilnius_incremental_task` in `./etl/ecs.tf`. Or not.

## Tags

L2 - level 2 of C4 model (e.g. "ETL", "WEB")
<br>
L3 - level 3 of C4 model (e.g. "ingest", "transform" for "ETL")
