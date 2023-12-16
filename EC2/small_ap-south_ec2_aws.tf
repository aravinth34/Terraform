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

resource "aws_instance" "example_server" {
  ami           = "ami-04708942c263d8190" //Amazon linux ami-02a2af70a66af6dfb
  instance_type = "t2.small"
  key_name      = "mumbai_linux_pem"
  vpc_security_group_ids = ["sg-092ff5b85daa63af0"]
  subnet_id     = "subnet-0b3a3a3a2f271cb3b"
  count         = 1
  
  tags = {
    Name = "nginx_test"
  }
}
