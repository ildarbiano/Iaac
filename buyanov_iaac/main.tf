terraform {
  backend "s3" {
    
    bucket = "ilyaterraformrf"
    region = "us-east-1"
    key = "s3-backup/tfstate"
  }
}
  
/* Specify access details
provider - это конкретное облако - GCP, DO, AWS, YANDEX и др 
Содержат настройки аутентификации и подключения к платформе или сервису
Предоставляют набор ресурсов для управления
Могут использоваться в модулях (начиная с версии 0.10.0) - Поддержка большого количества сервисов с API: AWS, Google Cloud, GitHub, PowerDNS, VCloud etc.*/
	
provider "aws" {
  region = "us-east-1"
  
}
############# Create a VPC ######################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "Quest VPC"
  }
}
############## Create an internet gateway################
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Quest VPC IG"
  }
}

##################### Declare the data source################
data "aws_availability_zones" "available" {
}

############### Create a subnet#############################
resource "aws_subnet" "web_subnet_az" {
  count = 2

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Quest Public Subnet AZ${count.index} - ${data.aws_availability_zones.available.names[count.index]}"
  }
  depends_on = [aws_internet_gateway.gw]
}

################# Grant public access on Internet Gateway######################
resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Quest Public Route Table"
  }
}

############### Associate the public subnets with the route table##############
resource "aws_route_table_association" "web_subnets_assotiations" {
  count = 2

  subnet_id      = aws_subnet.web_subnet_az[count.index].id
  route_table_id = aws_route_table.r.id
}
###################Create Security Group##########
resource "aws_security_group" "nodejs_Server" {
  name        = "Web Server Traffic"
  description = "Allow all inbound http traffic"
  vpc_id      = aws_vpc.main.id

  # HTTP access from anywhere
  dynamic "ingress" {
   for_each = ["80", "443", "3000","22"]

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 

############# EC2 instances creation#########
data "aws_availability_zones" "for_web"{}
data "aws_ami" "amazon-linux-2" {
  owners = ["amazon"]
  most_recent = true
 filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "web_server" {
  count = 1
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  key_name      = "window"
  monitoring    = true
  subnet_id     = aws_subnet.web_subnet_az[count.index].id
  # Our Security group to allow inbound HTTP and SSH access
  vpc_security_group_ids = [aws_security_group.nodejs_Server.id]
  tags = {
    Name        = "Quest Server ${count.index}"
    Terraform   = "true"
  }
  user_data = <<-EOF
              #!bin/bash
	#install nessesary package		  
        sudo yum update –y
        sudo yum install git -y
        sudo amazon-linux-extras install docker -y
        sudo service docker start -y
        sudo usermod -a -G docker ec2-user -y
 	#create directory and deploy nodejs 		  
			 EOF
			  
}

############ Public ip assig EC2 intances##############
resource "aws_eip" "web_server_eip" {
  count = 1

  vpc        = true
  instance   = aws_instance.web_server[count.index].id
  depends_on = [aws_internet_gateway.gw]
}
############ Create certificate for LoadBalancer ##############
resource "tls_self_signed_cert" "example" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.test.private_key_pem

  subject {
    common_name  = "server.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.test.private_key_pem
  certificate_body = tls_self_signed_cert.example.cert_pem
}
resource "tls_private_key" "test" {
  algorithm = "RSA"
}


