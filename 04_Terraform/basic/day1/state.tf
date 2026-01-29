terraform {
  backend "s3" {
    bucket       = "tf-state-ogmn6xw0"
    key          = "day1/terraform.tfstate"
    region       = "ap-southeast-1"
    profile      = "default"
    encrypt      = true
    use_lockfile = true
  }
}