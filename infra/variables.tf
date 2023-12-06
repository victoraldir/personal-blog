variable "domain_name" {
  type    = string
  default = "vhmontes.com"
}

variable "subdomain_name" {
  type    = string
  default = "blog"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}

variable "bucket_name" {
  type    = string
  default = "victoraldirblogbucket"
}

variable "terraform_state_bucket_name" {
  type    = string
  default = "blogvictoraldir-terraform-state"

}

variable "terraform_state_bucket_key" {
  type    = string
  default = "blog/terraform.tfstate"
}

variable "aws_account_id" {
  type    = string
  default = "915887201635"
}