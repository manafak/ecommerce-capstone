terraform {

  backend "s3" {
    bucket  = "kah-alt-sockshop-test-007"
    key     = "eks-cluster/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

}
