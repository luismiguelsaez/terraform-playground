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
  name   = "allow_ssh_all"
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

resource "aws_key_pair" "main" {
  key_name   = "elasticsearch"
  public_key = file("../../../../common/ssh/key/id_rsa.pub")
}

resource "aws_instance" "elasticsearch" {
  ami             = data.aws_ami.this.id
  instance_type   = "t3.medium"
  key_name        = "elasticsearch"
  security_groups = [aws_security_group.this.id]
  subnet_id       = var.subnet_id

  user_data            = file("files/user-data.sh")
  iam_instance_profile = aws_iam_instance_profile.this.name
}