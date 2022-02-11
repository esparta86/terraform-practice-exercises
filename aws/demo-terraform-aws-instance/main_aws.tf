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
# check variablees.tf 
# @default_tags contains default tags to inject into resources
# @vpc_tags contains the name of vpc
resource "aws_vpc" "development_vpc" {
  cidr_block = var.development_vpc_cidr
  instance_tenancy = "default"  
  tags = merge(var.default_tags,var.vpc_tags)
}




#Create Internet Gateway and attach VPC
# check variablees.tf 
# @default_tags contains default tags to inject into resources
# @igw_tags contains the name of Intenet Gateway
resource "aws_internet_gateway" "IGW_development" {
  vpc_id = aws_vpc.development_vpc.id  # vpc id will take the value of vpc id when is created
  tags = merge(var.default_tags,var.igw_tags)
}


#Create a public subnet
# check variablees.tf 
# @default_tags contains default tags to inject into resources
# @public_subnet_tags contains the name of public subnet
# @develop_public_subnet_cidr contains the CIDR that subnet is going to use
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.development_vpc.id
  cidr_block = var.develop_public_subnet_cidr
  tags = merge(var.default_tags,var.public_subnet_tags)
}

#Create a private subnet
# check variablees.tf 
# @default_tags contains default tags to inject into resources
# @private_subnet_tags contains the name of private subnet
# @develop_private_subnet_cidr contains the CIDR that subnet is going to use
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.development_vpc.id
  cidr_block = var.develop_private_subnet_cidr
  tags = merge(var.default_tags,var.private_subnet_tags)
}



#Route table for public subnets
# @default_tags contains default tags to inject into resources
resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.development_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    # Traffic from public subnets reaches the Internet via Internet Gateway created
    gateway_id = aws_internet_gateway.IGW_development.id
  }

  tags = merge(var.default_tags,{
     "Name" = "publicRT"
  })
}


#Route table for private subnets
# @default_tags contains default tags to inject into resources
resource "aws_route_table" "privateRT" {
  vpc_id = aws_vpc.development_vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    # Traffic from private subnets reaches the Internet via NAT Gateway.
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


#Creating Elastic IP addresses for NAT Gateway
# @default_tags contains default tags to inject into resources
resource "aws_eip" "natIP" {
  vpc = true 
  tags = merge(var.default_tags,{
    "Name" = "elasticIPNatGW"
  })
}

#Creating the NAT gateway using the subnet id and allocation id
# Review the sample https://aws.amazon.com/premiumsupport/knowledge-center/nat-gateway-vpc-private-subnet/
# IMPORTANT!
# - To create a NAT gateway is required to have a public subnet that is going to host the NAT gateway
#   The route table for the PUBLIC subnet should contains a route to the Internet through an Internet gateway
# - Provision an unattached Elastic IP address (EIP)
# - You need to update the route table of the private subnet hosting the EC2 instances that need internet access
resource "aws_nat_gateway" "natGW" {
  allocation_id = aws_eip.natIP.id  #Elastic IP ID
  subnet_id = aws_subnet.public_subnet.id
  
  tags = merge(var.default_tags,{
    "Name" = "natGateway"
  })

  depends_on = [
    aws_eip.natIP
  ]
}


# Creating the first NGINX server on public subnet
# @instance_ami contains the ami id of UBUNTU linux distribution
# The EC2 requires a security group, that security group let us 
#  - Access to the content through 80 port
#  - Access using ssh through 22 port
#  - Test a ping command.
# setup-nginx.sh contains all script bash command to install an nginx server
# key_name is important if you are going to associate a key to access to the server through ssh
resource "aws_instance" "app_server" {
  ami           = var.instance_ami
  instance_type = "t2.medium"

  depends_on = [
    aws_security_group.security_group
  ]

  vpc_security_group_ids = [ aws_security_group.security_group.id ]
  
  subnet_id = aws_subnet.public_subnet.id
  
  user_data = "${file("setup-nginx.sh")}"

  tags = merge(var.default_tags,{
    Name = var.instance_name
  })

  key_name = "ubuntu"
}


#Creating Elastic IP addresses  and associate with the web server created
resource "aws_eip" "publicIPServer01" {
  vpc = true

  instance = aws_instance.app_server.id
  tags = merge(var.default_tags,{
    "Name" = "publicIPServer01"
  })

}


# resource "aws_instance" "app_server_private" {
#   ami = var.instance_ami
#   instance_type = "t2.medium"


#   user_data = "${file("setup-nginx.sh")}"

#   subnet_id = aws_subnet.private_subnet.id
#   tags = merge(var.default_tags,{
#     Name = var.instance_name02
#   })

# }



#Creating Elastic IP addresses

# resource "aws_eip" "publicIPServer02" {
#   vpc = true
#   instance = aws_instance.app_server_private.id
#   tags = merge(var.default_tags,{
#     "Name" = "publicIPServer02"
#   })

# }



#Creating security group
resource "aws_security_group" "security_group" {

  depends_on = [
    aws_vpc.development_vpc
  ]

  name =  "security_group_development_pvc"
  vpc_id = aws_vpc.development_vpc.id

  ingress {
    description = "ICMP"
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

tags = var.default_tags
  
}












