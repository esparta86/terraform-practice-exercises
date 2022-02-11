variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type = string
  default = "nginx-server01"
}


variable "instance_name02" {
  description = "Value of the Name tag for the EC2 instance"
  type = string
  default = "nginx-server02"
}


variable "instance_ami" {
  description = "Value of the ami EC2"
  type = string
  default = "ami-0e472ba40eb589f49"
}

variable "development_vpc_cidr" {
  description = "cidr for vpc"
  type = string
  default = "10.0.0.0/24"
}

variable "develop_public_subnet_cidr" {
  description = "cidr for subnet vpc"
  type = string
  default = "10.0.0.0/26"
}

variable "develop_private_subnet_cidr" {
  description = "cidr for subnet vpc"
  type = string
  default = "10.0.0.64/26"
}



variable "default_tags" {
  default = {
    cloudprovider = "aws"
    owner = "lisandro-devops"
  }

  description = "Default resource tags"
  type = map(string)

}


variable "vpc_tags" {
  description = "vpc name"
  type = map(string)
  default = {
    Name = "development_pvc"
  }
}


variable "igw_tags" {
  description = "tags igw_name"
  type = map(string)
  default = {
    "Name" = "IGW_development"
  }
}

variable "public_subnet_tags" {
  description = "tags for public subnet"
  type = map(string)
  default = {
    "Name" = "public_subnet"
  }
}

variable "private_subnet_tags" {
  description = "tags for private subnet"
  type = map(string)
  default = {
    "Name" = "private_subnet"
  }
}