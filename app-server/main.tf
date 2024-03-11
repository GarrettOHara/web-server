resource "aws_instance" "app_server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  tags                        = var.tags
  security_groups             = [aws_security_group.allow_web_traffic.id]
  associate_public_ip_address = true
  user_data                   = file("user-data.sh")
}

resource "aws_security_group" "allow_web_traffic" {
  name        = var.web_sg_name
  description = var.security_group_description

  ingress {
    description = "Allow HTTP web traffic"
    from_port   = var.ingress_port
    to_port     = var.ingress_port
    protocol    = var.protocol
    cidr_blocks = var.cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}
