provider "aws" {
  region  = var.region  # This will be us-east-2
  profile = "joseph"
  allowed_account_ids = ["879381246410"]
  default_tags {
    tags = {
      environment = var.env
      managedby   = "terraform"
    }
  }
}

# Add provider configuration for us-east-1 (required for CloudFront certificates)
provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  profile = "joseph"
  allowed_account_ids = ["879381246410"]
  default_tags {
    tags = {
      environment = var.env
      managedby   = "terraform"
    }
  }
}