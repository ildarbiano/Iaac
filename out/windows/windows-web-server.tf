# Build WebServer duting Booststrap
provider "aws" {
    region="us-east-1"
}
/*Find latest AMI ID for Windows for any region where the instance start*/
data "aws_ami" "latest_aws_windows_rus_ami" {         #AMI of Microsoft Windows Server 2019 Base
  most_recent = true
  owners = ["801119661308"]
  filter {
    name = "name"
    values = ["Windows_Server-2019-Russian-Full-Base-*"]
  }
}
resource "aws_instance" "server_wind" {
    count = 1
    ami = data.aws_ami.latest_aws_windows_rus_ami.id  #AMI of Microsoft Windows Server 2019 Base
    instance_type = "t2.micro"
    key_name = "terraform-key"
    security_groups = ["${aws_security_group.window_ws_rdp.name}"]
    tags = {
    Name = "Windows Serv 2019 Russian"
    Owner = "BIV"
    Project = "terraform L_web_serv"
    }
    vpc_security_group_ids = [aws_security_group.window_ws_rdp.id]
    
    #Configurate Volume of Elastic Block Store
    root_block_device { 
    volume_size           = "30"
    volume_type           = "standard"
    delete_on_termination = "true"
    }
    volume_tags = {
    Name = "Windows WS Volume"
    }
    
/*
 Bootstraping is commands for automaticle start/ EOF-end of file
# it's shell script
   user_data = <<EOF
#!/bin/bash
yum -y update                                     #update linux
yum -y install httpd                              #install Apache web server
myip= 'curl http://169.254.169.254/latest/meta-data/local-ipv4'                                     #read local AWS IP-address of server
echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform!!!" > /var/www/html/index.html        #echo the phrase in this file of the web server
sudo service httpd start                          #start Apache server
chkconfig httpd on                                #command for restart with Apache
EOF
*/
}

resource "aws_security_group" "window_ws_rdp" {
  name        = "window_rdp"
  description = "Allow RDP inbound traffic"
  # vpc_id      = aws_vpc.main.id - we can't write because will be Default 

 # incoming traffic. HTTP, https, RDP
  dynamic "ingress" {

    for_each = ["80","443","3389"] 
    
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
    Name = "Windows SG RDP"    # Name of Security Group because it in this resourse
  }
}
