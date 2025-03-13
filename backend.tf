terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_YOUR_BUCKET_NAME"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
