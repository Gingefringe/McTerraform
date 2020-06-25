terraform {
  backend "s3" {
    profile        = "minecraft-deploy"
    bucket         = "gingefringe-tf-state-new"
    key            = "mc-static.tfstate"
    region         = "eu-west-2"
    encrypt        = true
  }
}

provider "aws" {
  profile = var.aws-profile
  region  = var.aws-region
  version = "~> 2.43"
}

provider "archive" {
  version = "~> 1.0"
}
