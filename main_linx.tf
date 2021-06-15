terraform {
  backend "s3" {        #--создание места хранения .tfstate 
    bucket = "astra-simple-web-shop"
    key = "linx_Web_Server.tfstate"
  }
}

provider "aws" {
    profile = "default"
    region  = var.aws-region
}