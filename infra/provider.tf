
provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us"
}

terraform {
  backend "s3" {
    bucket = "blogvictoraldir-terraform-state"
    key    = "blog/terraform.tfstate"
    region = "us-east-1"
  }
}
