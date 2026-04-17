# Remote State Architecture & AWS Deployment

This Terraform project automatically deploys a secure AWS architecture utilizing an automated Jenkins pipeline and robust AWS S3 Remote State management to prevent workspace conflicts.

## Architecture Deployed
- **Networking**: Custom VPC, 1 Public Subnet, 1 Private Subnet, Internet Gateway, NAT Gateway, Route Tables.
- **SSH Key**: Dynamically generates and manages a secure 4096-bit RSA key pair.
- **Compute**: 
  - 1 Linux EC2 Instance (Public Subnet) acting as an NGINX Web Server open to the internet.
  - 1 Linux EC2 Instance (Private Subnet) completely blocked from direct internet access.

---

## 1. Local Initialization (Standard Usage)

When working on this repository locally, standard Terraform workflow commands apply. **Terraform will automatically pull your secure state from S3** for all of these:

```bash
# 1. Initialize downloading of modules and S3 backend sync
terraform init

# 2. Preview changes that will be made
terraform plan

# 3. Apply the changes to AWS
terraform apply -auto-approve

# 4. Tear down the 17 deployed resources safely
terraform destroy -auto-approve
```

---

## 2. Jenkins Pipeline Automation

Since we moved the `terraform.tfstate` into AWS S3, Jenkins runs completely hands-free!

When you commit changes to `master`, Jenkins will automatically:
- Checkout the repository
- Run `terraform init` to sync with the S3 Bucket
- Run `terraform plan & apply` to safely spin your instances up

> **Note:** To prevent Jenkins from immediately wiping out what it builds, the automatic `terraform destroy` block was removed from the Jenkinsfile. You can use the local command above, or a second pipeline, when you are ready to destroy.

---

## 3. Remote Backend Commands (Manual Emergency Use)

**You do NOT have to run these commands normally.** They were already run to initially create the S3 bucket and DynamoDB table before you started. 

If you accidentally delete your S3 bucket or DynamoDB table from the AWS console, your Terraform will **hard crash**. To fix it, you will need to open your terminal and recreate the exact resources listed in `provider.tf` by copy-pasting the following:

**Recreate S3 Bucket:**
```bash
aws s3api create-bucket \
  --bucket terraform-state-aswathi-497645774924 \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

aws s3api put-bucket-versioning \
  --bucket terraform-state-aswathi-497645774924 \
  --versioning-configuration Status=Enabled
```

**Recreate DynamoDB Lock Table:**
```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```
