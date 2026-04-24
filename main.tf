#############################################
# TERRAFORM CONFIG
#############################################
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#############################################
# PROVIDER
#############################################
provider "aws" {
  region = "us-east-1"
}

#############################################
# DATA - Ubuntu 24.04 LTS (siempre el más reciente)
#############################################
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical oficial

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_caller_identity" "current" {}

#############################################
# VPC
#############################################
resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "AUY1105-Tapia-Ochoa-vpc"
  }
}

#############################################
# DEFAULT SG BLOQUEADO
#############################################
resource "aws_default_security_group" "default" {
  vpc_id  = aws_vpc.main.id
  ingress = []
  egress  = []
}

#############################################
# SUBNET PÚBLICA
#############################################
resource "aws_subnet" "subnet_public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "AUY1105-Tapia-Ochoa-subnet"
  }
}

#############################################
# SECURITY GROUP - Solo SSH entrante
#############################################
resource "aws_security_group" "sg" {
  name        = "AUY1105-Tapia-Ochoa-sg"
  description = "Security group que permite solo SSH entrante"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # Solo redes internas, NO 0.0.0.0/0
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AUY1105-Tapia-Ochoa-sg"
  }
}

#############################################
# KMS KEY
#############################################
resource "aws_kms_key" "logs_key" {
  description             = "KMS key para CloudWatch Logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "AUY1105-Tapia-Ochoa-kms"
  }
}

#############################################
# CLOUDWATCH LOG GROUP
#############################################
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/AUY1105-Tapia-Ochoa-flow-logs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.logs_key.arn

  tags = {
    Name = "AUY1105-Tapia-Ochoa-loggroup"
  }
}

#############################################
# IAM ROLE FLOW LOGS
#############################################
resource "aws_iam_role" "flow_logs_role" {
  name = "AUY1105-Tapia-Ochoa-flowlogs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "AUY1105-Tapia-Ochoa-flowlogs-role"
  }
}

resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "AUY1105-Tapia-Ochoa-flowlogs-policy"
  role = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = format("%s:*", aws_cloudwatch_log_group.vpc_flow_logs.arn)
      }
    ]
  })
}

#############################################
# VPC FLOW LOGS
#############################################
resource "aws_flow_log" "vpc_flow_logs" {
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
  iam_role_arn         = aws_iam_role.flow_logs_role.arn

  tags = {
    Name = "AUY1105-Tapia-Ochoa-flowlog"
  }
}

#############################################
# IAM ROLE EC2
#############################################
resource "aws_iam_role" "ec2_role" {
  name = "AUY1105-Tapia-Ochoa-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "AUY1105-Tapia-Ochoa-ec2-role"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "AUY1105-Tapia-Ochoa-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

#############################################
# EC2 - Ubuntu 24.04 LTS - t3.micro
#############################################
resource "aws_instance" "ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = false

  monitoring    = true
  ebs_optimized = true

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "AUY1105-Tapia-Ochoa-ec2"
  }
}
