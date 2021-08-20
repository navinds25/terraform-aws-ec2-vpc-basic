terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

resource "aws_vpc" "ec2_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = var.vpc_tags
}

# Subnets
resource "aws_subnet" "ec2_subnet_public" {
  vpc_id            = aws_vpc.ec2_vpc.id
  for_each          = { for idx, record in var.public_subnets : idx => record }
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = each.value.name
  }
}

resource "aws_subnet" "ec2_subnet_private" {
  vpc_id            = aws_vpc.ec2_vpc.id
  for_each          = { for idx, record in var.private_subnets : idx => record }
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = each.value.name
  }
}

# Security Groups
resource "aws_security_group" "vpc_ingress" {
  vpc_id = aws_vpc.ec2_vpc.id
  dynamic "ingress" {
    for_each = toset(var.vpc_sg_ingress)
    content {
      description = lookup(ingress.value, "name", "")
      from_port   = lookup(ingress.value, "start_port_range", "")
      to_port     = lookup(ingress.value, "end_port_range", "")
      protocol    = lookup(ingress.value, "protocol", "")
      cidr_blocks = lookup(ingress.value, "cidr_blocks", "")
    }
  }
  dynamic "egress" {
    for_each = toset(var.vpc_sg_egress)
    content {
      description = lookup(egress.value, "name", "")
      from_port   = lookup(egress.value, "start_port_range", "")
      to_port     = lookup(egress.value, "end_port_range", "")
      protocol    = lookup(egress.value, "protocol", "")
      cidr_blocks = lookup(egress.value, "cidr_blocks", "")
    }
  }
}

# Instances
resource "aws_instance" "server" {
  for_each               = { for idx, record in var.instances : idx => record }
  ami                    = "ami-04db49c0fb2215364"
  instance_type          = each.value.instance_type
  subnet_id              = each.value.public ? aws_subnet.ec2_subnet_public[each.value.subnet_index].id : aws_subnet.ec2_subnet_private[each.value.subnet_index].id
  vpc_security_group_ids = [aws_security_group.vpc_ingress.id]
  key_name               = aws_key_pair.ec2_key.key_name
  tags = {
    Name = each.value.name
  }
}

resource "aws_eip" "eip" {
  vpc = true
  for_each = { for idx, record in var.instances : idx => record
  if record.public }
  instance = aws_instance.server[each.key].id
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2_key"
  public_key = var.instance_public_key
}

# Routes
resource "aws_route_table" "main_ec2_route_table" {
  vpc_id = aws_vpc.ec2_vpc.id
  tags = {
    Name = "main_ec2_route_table"
  }
}

resource "aws_main_route_table_association" "main_ec2_vpc_route_table_association" {
  vpc_id         = aws_vpc.ec2_vpc.id
  route_table_id = aws_route_table.main_ec2_route_table.id
}

# public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.ec2_vpc.id
  tags = {
    Name = "ec2-public-route-table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  route_table_id = aws_route_table.public_route_table.id
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.ec2_subnet_public[count.index].id
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# private route table
resource "aws_route_table" "private_route_table" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.ec2_vpc.id
  tags = {
    Name = "ec2-private-route-table-${count.index}"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = length(var.private_subnets)
  route_table_id = aws_route_table.private_route_table[count.index].id
  subnet_id      = aws_subnet.ec2_subnet_private[count.index].id
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ec2_vpc.id

}

resource "aws_eip" "natgw" {
  count = length(var.public_subnets)
  vpc = true
}

resource "aws_nat_gateway" "natgw" {
  count = length(var.public_subnets)
  allocation_id = aws_eip.natgw[count.index].id
  subnet_id = aws_subnet.ec2_subnet_public[count.index].id
}

resource "aws_route" "natgw_route" {
  count = length(var.public_subnets)
  route_table_id   = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id   = aws_nat_gateway.natgw[count.index].id
}