provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "west"
  region = "us-west-1"
}
