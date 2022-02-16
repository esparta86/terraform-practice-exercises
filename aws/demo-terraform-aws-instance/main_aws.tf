terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}




# Creating the first NGINX server on public subnet
# @instance_ami contains the ami id of UBUNTU linux distribution
# The EC2 requires a security group, that security group let us 
#  - Access to the content through 80 port
#  - Access using ssh through 22 port
#  - Test a ping command.
# setup-nginx.sh contains all script bash command to install an nginx server
# key_name is important if you are going to associate a key to access to the server through ssh
# resource "aws_instance" "app_server" {
#   ami           = var.instance_ami
#   instance_type = "t2.medium"

#   depends_on = [
#     aws_security_group.security_group
#   ]

#   vpc_security_group_ids = [ aws_security_group.security_group.id ]

#   subnet_id = aws_subnet.public_subnet.id

#   user_data = "${file("setup-nginx.sh")}"

#   tags = merge(var.default_tags,{
#     Name = var.instance_name
#   })

#   key_name = "ubuntu"
# }





# resource "aws_instance" "app_server_private" {
#   ami = var.instance_ami
#   instance_type = "t2.medium"

#    depends_on = [
#     aws_security_group.sg_mysql
#   ]

#   vpc_security_group_ids = [ aws_security_group.sg_mysql.id]

#   user_data = "${file("setup-mysql.sh")}"

#   subnet_id = aws_subnet.private_subnet.id
#   tags = merge(var.default_tags,{
#     Name = var.instance_name02
#     purpose = "mysqldatabase"
#   })

#   key_name = "ubuntu"

# }







# Creating one NGINX server per subnet
# @instance_ami contains the ami id of UBUNTU linux distribution
# The EC2 requires a security group, that security group let us 
#  - Access to the content through 80 port
#  - Access using ssh through 22 port
#  - Test a ping command.
# setup-nginx.sh contains all script bash command to install an nginx server
# key_name is important if you are going to associate a key to access to the server through ssh
resource "aws_instance" "app_server_nginx" {
  count = length(var.azs)
  ami           = var.instance_ami
  instance_type = "t2.small"

  depends_on = [
    aws_security_group.security_group
  ]

  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  user_data = file("setup-nginx.sh")
  tags = merge(var.default_tags, {
    Name = "${var.instance_name_nginx}-${count.index}"
  })

  key_name = "ubuntu"
}