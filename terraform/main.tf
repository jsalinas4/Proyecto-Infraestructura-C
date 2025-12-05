terraform {
  required_version = ">= 0.15.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.29.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }

  backend "s3" {
    bucket         = "proyecto-infraestructura-tfstate-staging" # Cambiar según tu env
    key            = "terraform.tfstate"
    region         = "us-east-2"                                      # Cambiar según tu región
    dynamodb_table = "proyecto-infraestructura-tfstate-locks-staging" # Cambiar según tu env
    encrypt        = true
    # profile        = "joseph"
  }
}
