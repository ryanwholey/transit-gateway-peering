data aws_ami ubuntu {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "instance" {
  name        = var.name
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource aws_instance instance {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id     = var.subnet_ids[0]
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = {
    Name = var.name
  }
}
