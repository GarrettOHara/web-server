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
  user_data = data.template_file.user_data_template.rendered
  # user_data                   = file("user-data.sh")
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

  # Object file is required during user-data initiation
  depends_on = [aws_s3_bucket.this]
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

  inline_policy {
    name = "${var.name}-s3-access"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = ["s3:*"]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::${aws_s3_bucket.this.id}",
            "arn:aws:s3:::${aws_s3_bucket.this.id}/*"
          ]
        }
      ]
    })
  }

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

resource "aws_s3_bucket" "this" {
  # checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  # checkov:skip=CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled"
  # checkov:skip=CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration"
  # checkov:skip=CKV2_AWS_62: "Ensure S3 buckets should have event notifications enabled"
  # checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
  # checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default"
  # checkov:skip=CKV_AWS_186: No encryption needed for tests
  bucket        = "${var.name}-${random_string.random.result}"
  force_destroy = true
  tags = {
    Name = var.name
  }
}

# Generate random string to allow distinct S3 bucket name
resource "random_string" "random" {
  length  = 6
  upper   = false
  special = false
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "app_source_code" {
  # checkov:skip=CKV_AWS_186: No encryption needed for tests
  bucket = aws_s3_bucket.this.id
  key    = "app.py"
  source = "${path.module}/../app.py"
}
