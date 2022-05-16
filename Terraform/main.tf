terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

# Creating VPC here
 resource "aws_vpc" "my_vpc" {                
   cidr_block       = var.main_vpc_cidr     # Defining the CIDR block
   tags = {
     Name = "SmoothStack terraform"
   }
 }

# Creating Internet Gateway
 resource "aws_internet_gateway" "IGW" {    
    vpc_id     = aws_vpc.my_vpc.id             # vpc_id will be generated after we create VPC
    depends_on = [aws_vpc.my_vpc]
 }

# Creating Public Subnet
 resource "aws_subnet" "publicsubnets" {    
   vpc_id =  aws_vpc.my_vpc.id
   cidr_block = "${var.public_subnets}"        # CIDR block of public subnets
 }


# Creating Private Subnets
 resource "aws_subnet" "privatesubnets" {
   vpc_id =  aws_vpc.my_vpc.id
   cidr_block = "${var.private_subnets}"          # CIDR block of private subnets
 }

 resource "aws_route_table" "PublicRT" {    # Creating RT for Public Subnet
    vpc_id =  aws_vpc.my_vpc.id
         route {
    cidr_block = "${var.public_rt_cidr_block}"               # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.IGW.id
     }
 }

 resource "aws_route_table" "PrivateRT" {    # Creating RT for Private Subnet
   vpc_id = aws_vpc.my_vpc.id
   route {
   cidr_block = "0.0.0.0/0"             # Traffic from Private Subnet reaches Internet via NAT Gateway
   nat_gateway_id = aws_nat_gateway.NATgw.id
   }
 }

 resource "aws_route_table_association" "PublicRTassociation" {
    subnet_id = aws_subnet.publicsubnets.id
    route_table_id = aws_route_table.PublicRT.id
 }
 
 resource "aws_route_table_association" "PrivateRTassociation" {
    subnet_id = aws_subnet.privatesubnets.id
    route_table_id = aws_route_table.PrivateRT.id
 }

 # Creating elastic ip
 resource "aws_eip" "lb" {
   vpc   = true
 }
 
# Creating the NAT Gateway using subnet_id and allocation_id
# resource "aws_nat_gateway" "NATgw" {
#   allocation_id = aws_eip.lb.id
#   subnet_id = aws_subnet.publicsubnets.id
# }

 resource "aws_security_group" "allow_ssh" {
   name = "allow_ssh"
   description = "allow SSH inbound traffic"
   vpc_id = aws_vpc.my_vpc.id

   ingress {
     from_port = 22
     to_port = 22
     protocol = "tcp"
     cidr_blocks = [aws_vpc.my_vpc.cidr_block]
   }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   tags = {
     Name = "allow_ssh"
   }
   depends_on = [aws_vpc.my_vpc]
 }


terraform {
  backend "s3"{
    bucket = "aline-terraform-st"
    key = "networking-dev"
    region = "us-west-2"

  }
}

