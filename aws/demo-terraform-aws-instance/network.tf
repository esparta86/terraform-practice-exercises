locals {
  vpc_tags = {
    "subnet-dynamic-available" = "true",
  }
}



#Create VPC
# check variablees.tf 
# @default_tags contains default tags to inject into resources
# @vpc_tags contains the name of vpc
resource "aws_vpc" "development_vpc" {
  cidr_block       = var.development_vpc_cidr
  instance_tenancy = "default"
  tags             = merge(var.default_tags, var.vpc_tags)
}


#Create Internet Gateway and attach VPC
# check variablees.tf 
# @default_tags contains default tags to inject into resources
# @igw_tags contains the name of Intenet Gateway
resource "aws_internet_gateway" "IGW_development" {
  vpc_id = aws_vpc.development_vpc.id # vpc id will take the value of vpc id when is created
  tags   = merge(var.default_tags, var.igw_tags)
}

#Create a public subnet
# check variablees.tf 
# @default_tags contains default tags to inject into resources
# @public_subnet_tags contains the name of public subnet
# @develop_public_subnet_cidr contains the CIDR that subnet is going to use
# resource "aws_subnet" "public_subnet" {
#   vpc_id = aws_vpc.development_vpc.id
#   cidr_block = var.develop_public_subnet_cidr
#   tags = merge(var.default_tags,var.public_subnet_tags)
# }


#Create a private subnet
# check variablees.tf 
# @default_tags contains default tags to inject into resources
# @private_subnet_tags contains the name of private subnet
# @develop_private_subnet_cidr contains the CIDR that subnet is going to use
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.development_vpc.id
  cidr_block = var.develop_private_subnet_cidr
  tags       = merge(var.default_tags, var.private_subnet_tags)
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

  tags = merge(var.default_tags, {
    "Name" = "publicRT"
  })
}


#Route table for private subnets
# @default_tags contains default tags to inject into resources
# resource "aws_route_table" "privateRT" {
#   vpc_id = aws_vpc.development_vpc.id
#   route  {
#     cidr_block = "0.0.0.0/0"
#     # Traffic from private subnets reaches the Internet via NAT Gateway.
#     nat_gateway_id = aws_nat_gateway.natGW.id
#   }

#   tags = merge(var.default_tags,{
#     "Name" = "privateRT"
#   })

# }

# Route table Association with Public Subnet's
# resource "aws_route_table_association" "publicRTassociation" {
#   subnet_id = aws_subnet.public_subnet.id
#   route_table_id = aws_route_table.publicRT.id
# }

#Route table Association with private Subnets
# resource "aws_route_table_association" "privateRTassociation" {
#   subnet_id = aws_subnet.private_subnet.id
#   route_table_id = aws_route_table.privateRT.id
# }


#Creating Elastic IP addresses for NAT Gateway
# @default_tags contains default tags to inject into resources
# resource "aws_eip" "natIP" {
#   vpc = true 
#   tags = merge(var.default_tags,{
#     "Name" = "elasticIPNatGW"
#   })
# }

#Creating the NAT gateway using the subnet id and allocation id
# Review the sample https://aws.amazon.com/premiumsupport/knowledge-center/nat-gateway-vpc-private-subnet/
# IMPORTANT!
# - To create a NAT gateway is required to have a public subnet that is going to host the NAT gateway
#   The route table for the PUBLIC subnet should contains a route to the Internet through an Internet gateway
# - Provision an unattached Elastic IP address (EIP)
# - You need to update the route table of the private subnet hosting the EC2 instances that need internet access
# resource "aws_nat_gateway" "natGW" {
#   allocation_id = aws_eip.natIP.id  #Elastic IP ID
#   subnet_id = aws_subnet.public_subnet.id

#   tags = merge(var.default_tags,{
#     "Name" = "natGateway"
#   })

#   depends_on = [
#     aws_eip.natIP
#   ]
# }


#Creating Elastic IP addresses  and associate with the web server created
# resource "aws_eip" "publicIPServer01" {
#   vpc = true

#   instance = aws_instance.app_server.id
#   tags = merge(var.default_tags,{
#     "Name" = "publicIPServer01"
#   })

# }


#Creating security group for NGINX server
resource "aws_security_group" "security_group" {

  depends_on = [
    aws_vpc.development_vpc
  ]

  name   = "security_group_development_pvc"
  vpc_id = aws_vpc.development_vpc.id

  #Best practice, not enable it
  # ingress {
  #   description = "ICMP"
  #   from_port = 8
  #   to_port = 0
  #   protocol = "icmp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.default_tags

}

# #Creating security group for MYSQL server

# resource "aws_security_group" "sg_mysql" {
#   depends_on = [
#     aws_vpc.development_vpc
#   ]

#   name = "sg for mysql EC2"
#   description = "Allow mysql inbound traffic"

#   vpc_id = aws_vpc.development_vpc.id


#   ingress {
#     description = "allow TCP"
#     from_port = 3306
#     to_port = 3306
#     protocol = "tcp"
#     security_groups = [aws_security_group.security_group.id]
#   }

#   ingress {
#     description = "allow SSH"
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     security_groups = [aws_security_group.security_group.id]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = [ "0.0.0.0/0" ]
#   }
# }





# Using the for_each , We are defining a var in variables.tf called subnets_vpc
# We are iterating the map object to create all subnets
# this way is not complete dynamic
# resource "aws_subnet" "subnets" {
#     for_each = var.subnets_vpc #Important to define what is the variable that contains the map object
#     vpc_id = aws_vpc.development_vpc.id 
#     tags = merge(var.default_tags, {
#         "Name" = each.key # Adding the name as tag.
#     })
#     availability_zone  = each.value.zone
#     cidr_block = each.value.cidr  
# }



resource "aws_subnet" "public_subnet" {
  count = length(var.azs)

  vpc_id                  = aws_vpc.development_vpc.id
  availability_zone       = element(var.azs, count.index)
  cidr_block              = cidrsubnet(var.development_vpc_cidr, 4, count.index + 1)
  map_public_ip_on_launch = false

  tags = merge(
    local.vpc_tags,
    {
      "Name" = "subnet-${count.index}-public"
    },
  )
}



# Route table Association with Public Subnet's
# We are going to use the same route for all subnets.
resource "aws_route_table_association" "publicRTassociation" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.publicRT.id
}

