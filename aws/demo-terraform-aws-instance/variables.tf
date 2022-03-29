
variable "aws_region" {
  description = "value of name of region"
  type        = string
  default     = "us-east-1"
}


variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "nginx-server01"
}

variable "instance_name_nginx" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "nginx-server"
}


variable "instance_name02" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "mysql-server01"
}


variable "instance_ami" {
  description = "Value of the ami EC2"
  type        = string
  default     = "ami-0e472ba40eb589f49"
}

variable "development_vpc_cidr" {
  description = "cidr for vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "develop_public_subnet_cidr" {
  description = "cidr for subnet vpc"
  type        = string
  default     = "10.0.0.0/26"
}

variable "develop_private_subnet_cidr" {
  description = "cidr for subnet vpc"
  type        = string
  default     = "10.0.0.64/26"
}



variable "default_tags" {
  default = {
    cloudprovider = "aws"
    owner         = "lisandro-devops"
  }

  description = "Default resource tags"
  type        = map(string)

}


variable "vpc_tags" {
  description = "vpc name"
  type        = map(string)
  default = {
    Name = "development_pvc"
  }
}


variable "igw_tags" {
  description = "tags igw_name"
  type        = map(string)
  default = {
    "Name" = "IGW_development"
  }
}

variable "public_subnet_tags" {
  description = "tags for public subnet"
  type        = map(string)
  default = {
    "Name" = "public_subnet"
  }
}

variable "private_subnet_tags" {
  description = "tags for private subnet"
  type        = map(string)
  default = {
    "Name" = "private_subnet"
  }

}





variable "subnets_vpc" {
  description = "Map of subnets to create in the region"
  type        = map(any)
  default = {

    "subnet1" = {
      zone = "us-east-1a"
      cidr = "10.0.1.0/26"
    }

    "subnet2" = {
      zone = "us-east-1b"
      cidr = "10.0.1.64/26"
    }

    "subnet3" = {
      zone = "us-east-1c"
      cidr = "10.0.1.128/26"
    }


    "subnet4" = {
      zone = "us-east-1d"
      cidr = "10.0.1.192/26"
    }

    "subnet5" = {
      zone = "us-east-1e"
      cidr = "10.0.2.0/26"
    }

    "subnet6" = {
      zone = "us-east-1f"
      cidr = "10.0.2.64/26"
    }

  }
}



variable "azs" {
  description = "The availability zones to spread nodes in"
  default = [
    "us-east-1a",
    "us-east-1b",
  "us-east-1c"]
  type = list(string)
}