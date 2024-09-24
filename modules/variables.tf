variable "vpc-euw-3" {
  type = string
  default = "vpc-029182d12dddf7b15"
}

variable "eu_subnets" {
  description = "This is a variable of type Map of objects"
  type = map(object({
    az = string,
    cidr = string
  }))
  sensitive= true
  default = {
    "subnet_a" = {
    az = "eu-west-3a",
    cidr = "172.31.0.0/20"
    },
  "subnet_b" = {
    az = "eu-west-3b",
    cidr = "172.31.16.0/20"
    },
  "subnet_c" = {
    az = "eu-west-3c",
    cidr = "172.31.32.0/20"
    }
  }
}

variable "security_group_id" {
  type= string
  sensitive= true
  default= "sg-0d93dbc044e715abb"

}

variable "ami" {
  type = object({
    id= string,
    instance_type= string
  }) 
  default = {
    id="ami-0cb0b94275d5b4aec",
    instance_type = "t2.micro"
  }
}

variable db_private_ip {
  type        = string
  default     = "172.31.16.1"
}
