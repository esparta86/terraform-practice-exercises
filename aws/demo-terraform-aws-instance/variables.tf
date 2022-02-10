variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type = string
  default = "ExampleAppServerInstance"
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