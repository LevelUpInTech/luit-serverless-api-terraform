# Architecture

```
        ┌─────────────┐    HTTPS    ┌──────────────────────┐
client ─┼────────────►│  API Gateway (HTTP API v2)         │
        └─────────────┘             │  - CORS               │
                                    │  - Throttling         │
                                    │  - Access logs → CW   │
                                    └──────────┬────────────┘
                                               │ AWS_PROXY
                                               ▼
                                    ┌──────────────────────┐
                                    │  Lambda (Python 3.12)│
                                    │  - IAM least-priv    │
                                    │  - Structured logs   │
                                    └──────────┬────────────┘
                                               │
                                               ▼
                                    ┌──────────────────────┐
                                    │  DynamoDB            │
                                    │  - on-demand billing │
                                    │  - PK + SK + GSI     │
                                    │  - PITR enabled      │
                                    └──────────────────────┘

State backend (created once via /bootstrap):
  S3 bucket  ──► holds terraform.tfstate (versioned, encrypted)
  DynamoDB   ──► state lock table
```

## Why each piece

**HTTP API v2 vs REST API**
- ~70% lower per-request cost
- Lower latency (skips many REST features you don't need)
- Native JWT auth support if you ever want to add it
- Simpler resource model in Terraform

**Lambda least-privilege IAM**
- The function role can only Get/Put/Update/Delete/Query/Scan against the specific DynamoDB table and its GSI
- No wildcard `dynamodb:*` and no other AWS service access
- This is what hiring managers want to see when they ask "how do you scope IAM?"

**DynamoDB PAY_PER_REQUEST**
- No capacity planning
- Auto-scales to zero — perfect for portfolio projects you spin up and down
- The PK/SK/GSI single-table pattern is industry standard for serverless apps

**Remote state with locking**
- Multiple engineers can run `terraform apply` without corrupting state
- S3 versioning gives you state rollback
- DynamoDB lock prevents simultaneous writes
- This is the "tell me about a Terraform incident" interview save
