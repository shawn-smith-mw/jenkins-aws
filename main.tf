terraform {
  backend "s3" {
    bucket = "shawn-terraform-backend-bucket"
    key    = "jenkins/terraform/state"
    region = "us-east-2"
  }
}