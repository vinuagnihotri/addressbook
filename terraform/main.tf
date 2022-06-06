terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.16.0"
    }
  }
}
provider "aws" {
  # Configuration options
  
  region = "ap-south-1"
}
# vpc
resource "aws_vpc" "ownvpc" {
  cidr_block = var.vpc_cidr_block
  tags={
    Name="${var.env}-vpc"
  }
}
 module "myserver-subnet"{
   source = "./modules/subnet"
   vpc_id = aws_vpc.ownvpc.id
   subnet_cidr_block = var.subnet_cidr_block
   az = var.az
   env = var.env
 }

 module "myserver-instance"{
     source = "./modules/webserver"
     vpc_id = aws_vpc.ownvpc.id
     subnet_id = module.myserver-subnet.subnet.id
     env = var.env
     instance_type = var.instance_type
 }
