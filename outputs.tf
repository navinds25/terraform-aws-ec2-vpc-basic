
output "vpc_id" {
  description = "id of the vpc"
  value       = aws_vpc.ec2_vpc.id
}

output "vpc_cidr_block" {
  description = "vpc cidr"
  value       = aws_vpc.ec2_vpc.cidr_block
}

output "private_subnet_cidr" {
  description = "list of cidr for private_subnets"
  value       = ["$aws_subnet.ec2_subnet_private.*.id"]
}

output "public_subnet_cidr" {
  description = "list of cidr for public subnets"
  value       = ["$aws_subnet.ec2_subnet_public.*.id"]
}

output "instance_eips" {
  description = "elastic ips for instances"
  value = ["$aws_eip.eip.*.address"]
}

output "natgw_eips" {
  description = "elastic ips for nat gateways"
  value = ["$aws_eip.natgw.*.address"]
}
