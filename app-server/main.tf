resource "aws_instance" "this" {
  # checkov:skip=CKV_AWS_8: Encrypted volume not needed for testing
  ami                  = data.aws_ami.this.id
  ebs_optimized        = true
  iam_instance_profile = aws_iam_instance_profile.this.name
  instance_type        = var.instance_type
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  monitoring = true
  root_block_device {
    encrypted = true
  }
  # subnet_id                   = module.vpc.private_subnets[1]
  user_data                   = file("user-data.sh")
  user_data_replace_on_change = true
  vpc_security_group_ids = [
    aws_security_group.allow_software_updates.id,
    aws_security_group.allow_web_traffic.id
  ]

  tags = {
    Name = var.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "this" {
  name        = var.name
  description = "Role for bastion instance with Systems Manager access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "SystemsManagerAccess"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]

  tags = {
    Name = var.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "this" {
  name = var.name
  role = aws_iam_role.this.name

  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "allow_software_updates" {
  name        = var.name
  description = "Allow software updates"

  egress {
    description = "HTTPS for updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS TCP for updates"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS UDP for updates"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "allow_web_traffic" {
  name        = var.web_sg_name
  description = "Allow web traffic"

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

