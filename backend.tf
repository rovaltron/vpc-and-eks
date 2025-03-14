terraform {
  backend "s3" {
    bucket         = "vpc-and-eks-terraform-state-list"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
