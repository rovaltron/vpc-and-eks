# Terraform Remote State Bootstrap

This configuration sets up the necessary AWS resources for storing Terraform state remotely.

## Resources Created

- S3 bucket for storing Terraform state files
- DynamoDB table for state locking
- Appropriate security configurations and encryption

## Usage

1. Initialize and apply the bootstrap configuration:
```bash
cd bootstrap
terraform init
terraform apply
```

2. When prompted, provide:
   - `state_bucket_name`: Globally unique name for your state bucket
   - Other variables will use defaults unless specified

3. After successful creation, update the backend configuration in `../backend.tf`:
   - Replace `REPLACE_WITH_YOUR_BUCKET_NAME` with your actual bucket name

4. Initialize the main Terraform configuration with the new backend:
```bash
cd ..
terraform init
```

## Security Features

- S3 bucket versioning enabled
- Server-side encryption enabled
- Public access blocked
- DynamoDB table with on-demand capacity

## Important Notes

- The S3 bucket has `prevent_destroy = true` to protect against accidental deletion
- Ensure your AWS credentials have appropriate permissions
- The DynamoDB table uses on-demand billing to minimize costs
