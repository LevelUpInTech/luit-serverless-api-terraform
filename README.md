# LUIT Serverless API — Terraform Module

Production-ready serverless API stack you can deploy in 90 seconds.

**Stack:** AWS HTTP API v2 (API Gateway) + Lambda (Python 3.12) + DynamoDB (on-demand) + S3/DynamoDB remote state.

This is the same architecture Fortune 500 teams use — packaged so LUIT Academy members can clone, deploy, and walk an interviewer through real Infrastructure as Code.

---

## What you'll deploy

| Resource | Why this choice |
|---|---|
| **API Gateway HTTP API v2** | ~70% cheaper and faster than REST API. CORS, throttling, and CloudWatch logs already wired. |
| **Lambda (Python 3.12)** | Least-privilege IAM, env vars from SSM Parameter Store, structured JSON logs to CloudWatch. |
| **DynamoDB (on-demand)** | Partition key + sort key + GSI. No capacity planning, pay-per-request. |
| **S3 + DynamoDB state backend** | Remote state with locking. No more `terraform.tfstate` in your repo. |

---

## Prerequisites

- AWS account with credentials configured (`aws configure`)
- Terraform >= 1.6 (`terraform -v`)
- Python 3.12 (only needed if you want to package Lambda layers locally)

---

## Quickstart

### 1. Clone and bootstrap state backend (one-time per AWS account)

```bash
git clone https://github.com/LevelUpInTech/luit-serverless-api-terraform
cd luit-serverless-api-terraform/bootstrap
terraform init
terraform apply
```

This creates the S3 bucket and DynamoDB lock table that store your remote state. You only run it once per AWS account.

### 2. Deploy the API stack

```bash
cd ..
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform apply
```

The output will give you the API endpoint URL. Hit it with curl:

```bash
curl "$(terraform output -raw api_endpoint)/items"
```

### 3. Tear down when you're done

```bash
terraform destroy
```

---

## Project structure

```
luit-serverless-api-terraform/
├── README.md
├── LICENSE
├── .gitignore
├── providers.tf            # AWS provider + remote state backend
├── variables.tf            # Inputs (project name, region, env)
├── main.tf                 # API Gateway + Lambda + DynamoDB wiring
├── outputs.tf              # API URL, table name, Lambda ARN
├── terraform.tfvars.example
├── bootstrap/              # One-time state backend setup
│   ├── main.tf
│   └── outputs.tf
├── src/                    # Lambda function code
│   ├── lambda_function.py
│   └── requirements.txt
└── docs/
    └── architecture.md
```

---

## What you'll learn (interview-ready)

After deploying this once, you can confidently answer:

1. **"Walk me through how you'd deploy a serverless API as code."** — You've done it. Show the repo.
2. **"Why HTTP API v2 over REST API?"** — Cost, latency, simpler config.
3. **"How do you handle Terraform state in a team setting?"** — S3 remote backend with DynamoDB locking. Show `bootstrap/`.
4. **"How do you give Lambda least-privilege access to DynamoDB?"** — IAM policy scoped to specific table actions only. Show `main.tf`.
5. **"How do you avoid hardcoding secrets?"** — SSM Parameter Store + Lambda env var references.

---

## License

MIT — fork it, ship it, put it on your resume.

— Built for [LUIT Academy](https://skool.com/luit-academy)
