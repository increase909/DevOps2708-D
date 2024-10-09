provider "aws" {
  region = "us-west-2"
  profile = "awsuser"
  
}
 
#S3 Backet and DynamoDB
 terraform {
  backend "s3" {
    bucket         = "tfbackstate2708"
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "tfbackstate2708"
    encrypt        = true
  }
}  
# Create a VPC  (Amazon Virtual Private Cloud (Amazon VPC)  
resource "aws_vpc" "aws04_VPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "04-VPC"
  }
}
#Create subnet to my VPC  
resource "aws_subnet" "aws04_subnet" {
  vpc_id = aws_vpc.aws04_VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2b"
  tags = {
    name = "SubnetToVPC"
  }
}
#Create Gateway to my VPC
resource "aws_internet_gateway" "aws04_Gateway" {
  vpc_id = aws_vpc.aws04_VPC.id
  tags = {
    name = "Gateway04VPC"
    Managedby = "Terraform"
  }
}
# Create a Route Table
resource "aws_route_table" "aws04_route_table" {
  vpc_id = aws_vpc.aws04_VPC.id

  route {
    cidr_block                = "0.0.0.0/0"
    gateway_id                = aws_internet_gateway.aws04_Gateway.id
  }

  tags = {
    Name = "RouteTable-04-VPC"
  }
}
# Associate the Route Table with the Subnet
resource "aws_route_table_association" "aws04_route_table_association" {
  subnet_id      = aws_subnet.aws04_subnet.id
  route_table_id = aws_route_table.aws04_route_table.id
}

# Security Group allow  80, 443, 22 
resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow HTTP, HTTPS, and SSH"
  vpc_id      = aws_vpc.aws04_VPC.id

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
    Name = "allow_traffic"
  }
}

#VM Ec2 
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  instance_type          = "t2.micro"
  key_name               = "dev2708"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.allow_traffic.id]
  #vpc_security_group_ids = ["sg-12345678"]
  subnet_id              = aws_subnet.aws04_subnet.id
  user_data              = file("userdata.tpl")
  associate_public_ip_address = true
  # Настройка root-блока (root disk)
  root_block_device = [
    {
    volume_size = 10  
    volume_type = "gp2"
    }
  ]
  # Дополнительный EBS блок (если требуется)
  ebs_block_device = [
    {
      device_name = "/dev/sdh"
      volume_size = 10   
      volume_type = "gp2"
    }
  ]
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}




