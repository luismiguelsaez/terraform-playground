data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami.name]
  }

  filter {
    name   = "virtualization-type"
    values = [var.ami.virtualization_type]
  }

  owners = var.ami.owners
}

resource "aws_security_group" "this" {
  name   = "allow_ssh"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH from everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = var.key_pair.name
  public_key = var.key_pair.public_key
}

resource "aws_instance" "this" {
  ami             = data.aws_ami.this.id
  instance_type   = var.instance_size
  key_name        = var.key_pair.name
  security_groups = [aws_security_group.this.id]
  subnet_id       = var.subnet_id
}