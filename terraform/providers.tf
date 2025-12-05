provider "aws" {
  region = var.region
  # profile             = "joseph"
  allowed_account_ids = ["879381246410"]
  default_tags {
    tags = {
      environment = var.env
      managedby   = "terraform"
    }
  }
}


provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  #profile             = "joseph"
  allowed_account_ids = ["879381246410"]
  default_tags {
    tags = {
      environment = var.env
      managedby   = "terraform"
    }
  }
}
