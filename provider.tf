terraform {
  backend "s3" {
    bucket         = "terraform-state-aswathi-497645774924"
    key            = "assignment/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}