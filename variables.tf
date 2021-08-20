variable "vpc_cidr" {
  description = "cidr for vpc"
  type        = string
}

variable "private_subnets" {
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
}

variable "public_subnets" {
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
}

variable "vpc_sg_ingress" {
  type = list(object({
    name             = string
    start_port_range = number
    end_port_range   = number
    protocol         = string
    cidr_blocks      = list(string)
  }))
  description = "list of ingress rules for vpc sg"
}

variable "vpc_sg_egress" {
  type = list(object({
    name             = string
    start_port_range = number
    end_port_range   = number
    protocol         = string
    cidr_blocks      = list(string)
  }))
  description = "list of egress rules for vpc sg"
}

variable "vpc_tags" {
  description = "VPC Tags to set"
  type        = map(string)
  default     = {}
}

variable "instances" {
  type = list(object(
    { name          = string
      instance_type = string
      ami           = string
      public        = bool
      #subnet        = string
      subnet_index = number
  }))
  description = "instances in ec2 vpc"
}

variable "instance_public_key" {
  type = string
}
