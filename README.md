# Useful commands for scrapy crawls:
- Full load  
`scrapy crawl aruodas -a -o ads.jsonl`
- Incremental load  
`scrapy crawl aruodas -a since="05112025" -o ads.jsonl`
- Setup AWS Creds (assuming auth and AWS_SSO_PROFILE env van)
`eval "$(aws configure export-credentials --profile $AWS_SSO_PROFILE --format env)"`

# Terraform
- Login to AWS and set env vars `source bash/setup_aws.sh`
- Init terraform `terraform init -backend-config=backend/backend-dev.hcl`
- Set \$JOB_REPO_URL `export JOB_REPO_URL=$(terraform output --raw {job_name})`