# Housing

Analytics for housing prices.

## Features

- Incremental and full scraping of listings
- Outputs JSON Lines for easy downstream processing
- Containerized scraper with Docker
- Infrastructure as code with Terraform

## Prerequisites

- Python 3.13
- [uv](https://docs.astral.sh/uv/) for dependency management
- Docker and Docker CLI
- Terraform
- AWS account with appropriate permissions (I use AWS SSO to login)

## Quick setup

1. For local run, install python libs
    - `uv sync --locked --no-install-project --extra scraping`
2. For running from Docker build an image
    - `docker build -f web_scraping/Dockerfile -t scraping .`
3. Terraform Infra setup can be found in [Infra README](infra/README.md)
4. Set `OUTPUT_BUCKET` and `OUTPUT_PREFIX` env vars (might be nonsense for local only)
5. Create a `crawl_meta.json` based on `web_scraping/crawl_meta.json.example`, populate it with your values, and put it to `OUTPUT_BUCKET` in `OUTPUT_PREFIX` directory. 

## Run data scraping locally

- Full load  
`scrapy crawl aruodas -a -o ads.jsonl`
- Incremental load  
`scrapy crawl aruodas -a since="05112025" -o ads.jsonl`
    > If AWS infra set up, since can be "auto" and spider will take last crawl date from `OUTPUT_BUCKET`

## Run data scraping from Docker

- With terraform infra setup, `./bash/run_scraping.sh` can be used

## AWS ECR Deployment

- Setup Terraform infra ([steps](infra/README.md#setup))
- `cd` to `infra/etl/` (we need an output from terraform)
- Setup AWS env vars:
    - `export AWS_REGION=$(aws configure get region --profile $AWS_PROFILE)`
    - `export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile $AWS_PROFILE --query Account --output text)`
    - `export ECR_LOGIN_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"`

    - `export REPO_URL=$(terraform output -raw {tf repo output, i.e. web_scraping_repo_url})`
- `cd` to repo root
- Build image (for web_scraping build `bash/build_scraping.sh` can be used)
    - `docker build -f {component, i.e. web_scraping}/Dockerfile -t $REPO_URL .`
- Deploy image
    - `./bash/ecr_deploy.sh`

## Debugging / Dev tips

- There is a VS Code debug config that requires AWS infra setup to work (be carefull with `OUTPUT_BUCKET`).

## Data analysis

Notebooks in [notebooks/](notebooks) use the scraped JSONL files (e.g., [ads.jsonl](ads.jsonl)) for EDA and plotting:
- [notebooks/eda.ipynb](notebooks/eda.ipynb)
- [notebooks/plots.ipynb](notebooks/plots.ipynb)
