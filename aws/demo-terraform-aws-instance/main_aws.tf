terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

#Create VPC
resource "aws_vpc" "development_vpc" {
  cidr_block = var.development_vpc_cidr
  instance_tenancy = "default"  
  tags = merge(var.default_tags,var.vpc_tags)
}


#Create Internet Gateway and attach VPC

resource "aws_internet_gateway" "IGW_development" {
  vpc_id = aws_vpc.development_vpc.id  # vpc id will take the value of vpc id when is created
  tags = merge(var.default_tags,var.igw_tags)
}


#Create a private Subnet

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.development_vpc.id
  cidr_block = var.develop_private_subnet_cidr
  tags = merge(var.default_tags,var.public_subnet_tags)
}

#Create a public subnet

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.development_vpc.id
  cidr_block = var.develop_public_subnet_cidr
  tags = merge(var.default_tags,var.private_subnet_tags)
}

#Route table for public subnets

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.development_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW_development.id
  }

  tags = merge(var.default_tags,{
     "Name" = "publicRT"
  })
}


#Route table for private subnets

resource "aws_route_table" "privateRT" {
  vpc_id = aws_vpc.development_vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natGW.id
  }

  tags = merge(var.default_tags,{
    "Name" = "privateRT"
  })
  
}

# Route table Association with Public Subnet's
resource "aws_route_table_association" "publicRTassociation" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.publicRT.id
}

#Route table Association with private Subnets

resource "aws_route_table_association" "privateRTassociation" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.privateRT.id

}


#Creating Elastic IP addresses

resource "aws_eip" "natIP" {
  vpc = true 
  tags = merge(var.default_tags,{
    "Name" = "elasticIPNatGW"
  })
}

#Creating the NAT gateway using the subnet id and allocation id

resource "aws_nat_gateway" "natGW" {
  allocation_id = aws_eip.natIP.id
  subnet_id = aws_subnet.public_subnet.id
  
  tags = merge(var.default_tags,{
    "Name" = "natGateway"
  })

  depends_on = [
    aws_eip.natIP
  ]
}


# resource "aws_instance" "app_server" {
#   ami           = var.instance_ami
#   instance_type = "t2.micro"

#   # user_data = <<-EOL
#   # #!/bin/bash -xe
#   # apt-get update && apt-get install -y nginx
#   # echo "NGINX INSTALLED"

#   # EOL

#   user_data = "${file("setup-nginx.sh")}"

#   tags = {
#     Name = var.instance_name
#   }
# }
