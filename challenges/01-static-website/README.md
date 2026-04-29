# Challenge 01: Deploy a Real Website to AWS in 30 Minutes

You're not cloning anything. You're typing it.

By the end of this challenge you'll have a real S3-hosted static website with a real public URL — versioning enabled, encryption at rest, and the right public access settings. The same pattern Fortune 500 teams use for marketing sites, status pages, and documentation portals.

---

## What you need (5 minutes to set up)

- AWS CLI installed and configured (`aws configure`)
- Terraform installed (`brew install terraform` on Mac, or download from terraform.io)
- A free 30 minutes

---

## How this works

Inside this folder you have:

- **`starter/`** — the incomplete code. This is where you work.
- **`solution/`** — the reference answer. **Don't peek until you've tried it for at least 20 minutes.**

Open the `starter/` folder. You'll find:

- `providers.tf` — done for you
- `main.tf` — partially done (bucket, website config, versioning, encryption are wired up; three things are missing)
- `index.html` — a starter HTML file ready to upload
- `README.md` — your task list

---

## Your assignment

The starter `main.tf` deploys a secure, encrypted, versioned S3 bucket configured for static website hosting. But if you `terraform apply` it right now and visit the URL, you'll get **AccessDenied**. That's not a bug. That's AWS doing its job.

Your job is to make it work — *without* compromising the security defaults already in place.

You need to add three things:

1. **Upload `index.html` to your bucket.** What Terraform resource handles uploading objects to S3?

2. **Open up public read access — but only for reading.** The default public-access block is on (good). You need to selectively allow GetObject on this specific bucket. Two resources work together to make this happen — find them.

3. **Add an `outputs.tf` that prints the website URL** so you don't have to dig through the AWS console to find it.

---

## Stuck? Here are hints, not answers

- The Terraform AWS provider has resources for almost every S3 capability. Search the registry for "s3 object."
- "Block all public access" can be enforced or relaxed via `aws_s3_bucket_public_access_block`. Read what each of its four flags actually does.
- Public bucket-level read access is granted via a **bucket policy** with the `s3:GetObject` action and a `Principal` of `"*"`. ACLs are the legacy way; use a policy.
- The website endpoint hostname is an attribute of `aws_s3_bucket_website_configuration`, not the bucket itself.

---

## Done? Drop proof in the LUIT Academy comments

Post:
1. Your live website URL (we'll click it)
2. A screenshot of your `terraform apply` output showing all green resources
3. One thing you got stuck on and how you figured it out (this is the most valuable post — others will learn from it)

Then compare your code to `solution/`. If your version is different but works, that's fine — there are multiple right answers.

---

## Interview connection

This challenge maps to two interview questions you will absolutely get asked:

- *"Walk me through how you'd host a static website on AWS."*
- *"How do you balance making content public with S3's security defaults?"*

After tonight you can answer both with a real story and a real repo on your GitHub.

---

## When you're ready for more

The full-stack version of this — Lambda + API Gateway + DynamoDB, deployed with Terraform — is the parent repo you're sitting in. Don't peek at the root `main.tf` until you've nailed this challenge. That's a Level 2 lab.

— LUIT Academy
