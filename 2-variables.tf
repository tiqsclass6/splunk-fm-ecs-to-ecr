variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_availability_zone" {
  type        = list(string)
  description = "Availability zone"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.240.0.0/16"
}

variable "public_subnet_config" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  default = {
    "public_subnet_1" = {
      cidr_block = "10.240.1.0/24"
      az         = "us-east-1a"
    }

    "public_subnet_2" = {
      cidr_block = "10.240.2.0/24"
      az         = "us-east-1b"
    }

    "public_subnet_3" = {
      cidr_block = "10.240.3.0/24"
      az         = "us-east-1c"
    }
  }
}

variable "private_subnet_config" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  default = {
    "splunk_subnet_1" = {
      cidr_block = "10.240.11.0/24"
      az         = "us-east-1a"
    }

    "splunk_subnet_2" = {
      cidr_block = "10.240.12.0/24"
      az         = "us-east-1b"
    }

    "splunk_subnet_3" = {
      cidr_block = "10.240.13.0/24"
      az         = "us-east-1c"
    }
  }
}