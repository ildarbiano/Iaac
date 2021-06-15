# Build WebServer duting Booststrap

/*Find latest AMI ID for AWS.Linux for any region where the instance start*/
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
    tags = {
    Name = "Linux AWS"
    Owner = "BIV"
    Project = "terraform L_web_serv"
    }
    vpc_security_group_ids = [aws_security_group.linux_web_server.id] #there is the link to instraction, but could link to existing Security group ID, in those format ["sg-05d7ff38f60e64657"]
    volume_tags = {
    Name = "Linux WebServ Volume"
    }

/*
/*-Bootstraping is commands for automaticle start/ EOF-end of file
it's shell script
   user_data = <<-EOF
#!/usr/bin/bash
sudo yum -y update                                                                                              #update linux
sudo yum -y install httpd                                                                                       #install Apache web server             
myip= 'curl http://169.254.169.254/latest/meta-data/local-ipv4'                                                                    #read local AWS IP-address of server
echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform on Linux AWS, changed of myself!!!" > /var/www/html/index.html       #echo the phrase in this file of the web server
sudo service httpd start                                                                                         #start Apache server
chkconfig httpd on                                                                                               #command for restart with Apache
EOF
*/
}

resource "aws_security_group" "linux_web_server" {
  name        = "linux_web_security_group"
  description = "Allow TLS inbound traffic"
  # vpc_id      = aws_vpc.main.id - #we can commenting because will be Default 

# incoming traffic. HTTP,https,SSH,UNIX-systems access from anywhere"
  dynamic "ingress" {

    for_each = ["80","443","22", "3000"] #3000 for Unix system
    
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"] # from anyway internet
    }
  }

  egress { # rules for out traffic from server
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # mean all of port and protocol
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Linux Serv SG"    # Name of Security Group because it in this resourse
  }
}

resource "aws_key_pair" "mobaLx" {
  key_name   = "Linux AWS Key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCeUPCJwBz5OEB0mwidKAND1U/91BzekSXkJ3/C35IrOPMNSDouTvd9qbLQfKyTwok9TiDxC5nJIfbnpQDacDnHke7dcL2N9oVSRx3nIDirwib73gZtMVYq+Gef7J7cws3Lp/b/RX/hQvf/kPvgFKOLrMj5N1dMUL05q2sZTBigWiIBkmC7e9ck32tU05TixmFL+drYSW+i318UT1HwhqbfrtRhl0MN+o/LaNsZhyc0HbSsTxysO5CmQtB0U6IAleuNe4gwCXgxuNDDbqsWEyHKT1LZ982mautFPUBMDLCdXpOUznHzsdN1qrU5FzrlClEUEE1jCm9vM6Y9sHG5xkSZ ilya@HP"
}

