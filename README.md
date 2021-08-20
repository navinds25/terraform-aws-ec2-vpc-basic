# AWS-EC2

## Instructions:

### Usage:
` See example folder `

### ssh key for instances:

` It is recommended that you specify the ssh public key in a file named terraform.tfvars. Please note, ec2_public_key is a variable present, ec2_infra.tf and not in the module. `

```
 ec2_public_key = "ssh-rsa AB3N....
```


## Caveats:

* Nat gateway will be added in each public subnet and corresponding index in private_subnets will be routed to it.
* Equal number of public and private subnets should be specified when using the module.