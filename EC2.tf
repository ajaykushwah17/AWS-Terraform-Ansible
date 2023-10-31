provider "aws" {
  region = "us-east-1"  # Change to your desired AWS region
}

# Random pet for naming
resource "random_pet" "sg" {}

# AWS VPC
resource "aws_vpc" "awsec2demo" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "vpc-quickcloudpocs"
  }
}

# AWS VPC Subnet
resource "aws_subnet" "awsec2demo" {
  vpc_id     = aws_vpc.awsec2demo.id
  cidr_block = "172.16.10.0/24"

  tags = {
    Name = "subnet-quickcloudpocs"
  }
}

# Security Group Rules
resource "aws_security_group" "awsec2demo" {
  name        = "${random_pet.sg.id}-sg"
  vpc_id      = aws_vpc.awsec2demo.id

  # Ingress rule for SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key Pair for SSH
resource "aws_key_pair" "example" {
  key_name   = "my-key-pair"  # Replace with your desired key pair name
  public_key = "your-public-ssh-key"  # Replace with your own public key
}

# AWS EC2
resource "aws_instance" "awsec2demo" {
  ami           = "ami-0dbc3d7bc646e8516"  # Replace with your desired AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.example.key_name  # Reference the key pair resource

  tags = {
    Name = "MyEC2Instance"  # Specify the desired name for your EC2 instance
  }

  network_interface {
    subnet_id          = aws_subnet.awsec2demo.id
    private_ips       = ["172.16.10.100"]
    security_groups   = [aws_security_group.awsec2demo.name]
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.public_ip}, playbook.yml"
    working_dir = "${path.module}"
  }
}

output "ec2_instance_id" {
  value = aws_instance.awsec2demo.id
}
