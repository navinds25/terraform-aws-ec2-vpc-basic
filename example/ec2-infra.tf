
provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

variable "ec2_public_key" {
  type = string
}

module "aws-ec2" {
  source   = "../"
  vpc_cidr = "10.101.0.0/16"
  public_subnets = [
    {
      name = "pubsub1"
      az   = "ap-south-1a"
      cidr = "10.101.1.0/24"
      }, {
      name = "pubsub2"
      az   = "ap-south-1b"
      cidr = "10.101.2.0/24"
    }
  ]
  private_subnets = [
    {
      name = "privsub1"
      az   = "ap-south-1a"
      cidr = "10.101.100.0/24"
    },
    {
      name = "privsub2"
      az   = "ap-south-1b"
      cidr = "10.101.101.0/24"
    }
  ]
  vpc_sg_ingress = [
    {
      name             = "ssh"
      start_port_range = 22
      end_port_range   = 22
      protocol         = "tcp"
      cidr_blocks      = ["106.51.130.30/31", "10.101.0.0/16"]
    }
  ]
  vpc_sg_egress = [
    {
      name             = "https"
      start_port_range = 443
      end_port_range   = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      }, {
      name             = "ssh"
      start_port_range = 22
      end_port_range   = 22
      protocol         = "tcp"
      cidr_blocks      = ["10.101.0.0/16"]
    }
  ]
  vpc_tags = {
    Name = "ec2-vpc"
  }
  instances = [{
    name          = "public_instance"
    instance_type = "t2.micro"
    ami           = "ami-04db49c0fb2215364"
    public        = true
    subnet_index  = 0
    }, {
    name          = "private_instance"
    instance_type = "t2.nano"
    ami           = "ami-04db49c0fb2215364"
    public        = false
    subnet_index  = 0
    },
    {
      name          = "public_instance"
      instance_type = "t2.nano"
      ami           = "ami-04db49c0fb2215364"
      public        = true
      subnet_index  = 1
      }, {
      name          = "private_instance"
      instance_type = "t2.nano"
      ami           = "ami-04db49c0fb2215364"
      public        = false
      subnet_index  = 1
    },
  ]
  instance_public_key = var.ec2_public_key
}
