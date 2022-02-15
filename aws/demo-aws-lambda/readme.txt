This example creates the following resources
- VPC
  - Public subnet
  - Private subnet
- Nginx Server EC2 deployed in Public subnet
- Mysql Server EC2 - mysql container deployed in Private subnet
- Security groups
  - Security group for Nginx server to have access through 80 port, 22 and ICMP
  - Security group for mysql server to have access through 3306 and 22
  