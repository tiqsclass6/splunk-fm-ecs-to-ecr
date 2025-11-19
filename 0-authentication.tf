terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.17"
    }
  }
}

terraform {
  backend "s3" {
    bucket  = "kubernetes-assignment-state-files"
    key     = "splunk-ecs-terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
