variable "region" {
    default = "us-west-2"
}
 variable "main_vpc_cidr" {
     type = string
     description = "IPv4 CIDR block to be assigned to the VPC"
 } 

 variable "public_subnets" {
     type = string
    description = "Public CIDR blocks"
 }

variable "private_subnets" {
     type = string
     description = "Private CIDR blocks"
 }

 variable "public_rt_cidr_block" {
     type = string
     description = "Public Route table CIDR Block"
 }
