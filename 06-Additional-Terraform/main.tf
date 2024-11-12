provider "aws" {
  region  = "us-west-2"
  profile = "awsuser"
}

terraform {
  backend "s3" {
    bucket         = "tfbackstate2708"
    key            = "terraform/state"
    region         = "us-west-2"
    dynamodb_table = "tfbackstate2708"
    encrypt        = true
  }
}


locals {
  name_prefix = "${var.project_name}-${var.environment_name}"
}

data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}


resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "${local.name_prefix}-subnet"
  }
}


resource "aws_internet_gateway" "main_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name       = "${local.name_prefix}-igw"
    Managed_by = "Terraform"
  }
}


resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gateway.id
  }

  tags = {
    Name = "${local.name_prefix}-route-table"
  }
}


resource "aws_route_table_association" "main_route_table_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_security_group" "allow_traffic" {
  name        = "${local.name_prefix}-sg"
  description = "Allow HTTP, HTTPS, and SSH"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-allow-traffic"
  }
}


module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name                   = "${local.name_prefix}-instance"
  instance_type          = var.instance_type               
  #ami                    = var.ami_id                      
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.latest_ubuntu.id
  monitoring             = var.monitoring                 
  vpc_security_group_ids = [aws_security_group.allow_traffic.id]
  subnet_id              = aws_subnet.main_subnet.id
  user_data              = file("userdata.tpl")
  associate_public_ip_address = true

  root_block_device = [
    {
      volume_size = var.root_block_device_size   
      volume_type = "gp2"
    }
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdh"
      volume_size = var.ebs_block_device_size    
      volume_type = "gp2"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = var.environment_name           
  }

}

