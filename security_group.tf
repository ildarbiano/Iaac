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
      cidr_blocks      = ["90.154.0.0/16"] #--0.0.0.0/0 from anyway internet
    }
  }

  egress { # rules for out traffic from server
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # mean all of port and protocol
    cidr_blocks      = ["0.0.0.0/16"]
  }

  tags = {
    Name = "Linux Serv SG"    # Name of Security Group because it in this resourse
  }
}

/*
resource "aws_key_pair" "mobaLx" {
  key_name   = "Linux_AWS_Key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCeUPCJwBz5OEB0mwidKAND1U/91BzekSXkJ3/C35IrOPMNSDouTvd9qbLQfKyTwok9TiDxC5nJIfbnpQDacDnHke7dcL2N9oVSRx3nIDirwib73gZtMVYq+Gef7J7cws3Lp/b/RX/hQvf/kPvgFKOLrMj5N1dMUL05q2sZTBigWiIBkmC7e9ck32tU05TixmFL+drYSW+i318UT1HwhqbfrtRhl0MN+o/LaNsZhyc0HbSsTxysO5CmQtB0U6IAleuNe4gwCXgxuNDDbqsWEyHKT1LZ982mautFPUBMDLCdXpOUznHzsdN1qrU5FzrlClEUEE1jCm9vM6Y9sHG5xkSZ ilya@HP"
}
*/
