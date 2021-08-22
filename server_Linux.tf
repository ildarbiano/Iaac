/*
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
    key_name = var.name_key_fingerprint
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
*/
