terraform {
  backend "s3" {
    bucket = "teste-alemacedo-terraform-state"
    key    = "trabalho-final/terraform.tfstate"
    region = "us-east-1"
  }
}