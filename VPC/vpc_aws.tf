terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "ap-south-1"
  profile = "default"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc_terraform"
  }
}
variable "public_subnet_cidrs" {
 type        = list(string)
 description = "PublicSubnet"
 default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["ap-south-1a", "ap-south-1b"]
}

resource "aws_subnet" "public_subnets" {
 count             = length(var.public_subnet_cidrs)
 vpc_id            = aws_vpc.main.id
 cidr_block        = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
//Enable auto-assign public IPv4 address
 map_public_ip_on_launch = true
 tags = {
   Name = "Subnet_Pub ${count.index + 1}"
 }
}

resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main.id
 tags = {
   Name = "IGW_Terra"
 }
}

resource "aws_route_table" "second_rt" {
 vpc_id = aws_vpc.main.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 tags = {
   Name = "Route_Pub"
 }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.second_rt.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_All"
  description = "Allow all tcp traffic"
  vpc_id      = aws_vpc.main.id

//Inbound rule
  ingress {
    description      = "All ssh VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  //  ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

//Inbound rule
  ingress {
    description      = "All http VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  //  ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
//Inbound rule
  ingress {
    description      = "All https VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  //  ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
//Inbound rule
  ingress {
    description      = "Jenkins"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  //  ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
//Outbound rule
  egress { 
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tcp22"
  }
}
