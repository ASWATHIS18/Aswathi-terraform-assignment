resource "aws_security_group" "nginx_sg" {
  name   = "nginx-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

# PUBLIC EC2 (NGINX)
resource "aws_instance" "public_vm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install nginx -y
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = { Name = "Public-NGINX" }
}

# PRIVATE EC2
resource "aws_instance" "private_vm" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet
  key_name      = var.key_name

  tags = { Name = "Private-VM" }
}
