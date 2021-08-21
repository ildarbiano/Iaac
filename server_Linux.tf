#--Find latest AMI ID for AWS.Linux for any region where the instance start
data "aws_ami" "latest_aws_linux_ami" {
  most_recent = true
  owners = ["137112412989"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }
}
resource "aws_instance" "server_linux" {
    count = 1
    ami = data.aws_ami.latest_aws_linux_ami.id  #AMI of Linux AWS 
    instance_type = "t2.micro"
    key_name = "Linux_AWS_Key"
    tags = {
    Name = "Linux AWS"
    Owner = "BIV"
    Project = "terraform L_web_serv"
    }
    #there is the link to instraction, but could link to existing Security group ID, in those format ["sg-05d7ff38f60e64657"]
    vpc_security_group_ids = [aws_security_group.linux_web_server.id] 
    volume_tags = {
    Name = "Linux WebServ Volume"
    }
}

resource "aws_security_group" "linux_web_server" {
  name        = "linux_web_security_group"
  description = "Allow TLS inbound traffic"
  # vpc_id      = aws_vpc.main.id - #we can commenting because will be Default vpc-2472c659

# incoming traffic. HTTP,https,SSH,UNIX-systems access from anywhere"
  dynamic "ingress" {

    for_each = ["80","443","22","3000"] #3000 for Unix system
    
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["46.242.0.0/16"] #--0.0.0.0/0 from anyway internet
    }
  }

  egress { # rules for out traffic from server
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # mean all of port and protocol
    cidr_blocks      = ["46.242.0.0/16"]
  }

  tags = {
    Name = "Linux Serv SG"    # Name of Security Group because it in this resourse
  }
}

resource "aws_key_pair" "mobaLx" {
  key_name   = "Linux_AWS_Key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCeUPCJwBz5OEB0mwidKAND1U/91BzekSXkJ3/C35IrOPMNSDouTvd9qbLQfKyTwok9TiDxC5nJIfbnpQDacDnHke7dcL2N9oVSRx3nIDirwib73gZtMVYq+Gef7J7cws3Lp/b/RX/hQvf/kPvgFKOLrMj5N1dMUL05q2sZTBigWiIBkmC7e9ck32tU05TixmFL+drYSW+i318UT1HwhqbfrtRhl0MN+o/LaNsZhyc0HbSsTxysO5CmQtB0U6IAleuNe4gwCXgxuNDDbqsWEyHKT1LZ982mautFPUBMDLCdXpOUznHzsdN1qrU5FzrlClEUEE1jCm9vM6Y9sHG5xkSZ ilya@HP"
}

