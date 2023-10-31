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

# AWS Network Interface
resource "aws_network_interface" "awsec2demo" {
  subnet_id    = aws_subnet.awsec2demo.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "NI-quickcloudpocs"
  }
}

# AWS Security Group
resource "aws_security_group" "awsec2demo" {
  name     = "${random_pet.sg.id}-sg"
  vpc_id   = aws_vpc.awsec2demo.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AWS EC2
resource "aws_instance" "awsec2demo" {
  ami           = "ami-0dbc3d7bc646e8516" # us-east-1
  instance_type = "t2.micro"

  tags = {
    Name = "MyEC2Instance"  # Specify the desired name for your EC2 instance
  }

  network_interface {
    network_interface_id = aws_network_interface.awsec2demo.id
    device_index        = 0
  }
}

# Create an Elastic IP (Public IP)
resource "aws_eip" "awsec2demo_eip" {
  instance = aws_instance.awsec2demo.id
}

# Create an Internet Gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.awsec2demo.id
}

# Create a Route Table Association
resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.awsec2demo.id
  route_table_id = aws_vpc.awsec2demo.default_route_table_id
}

# Create a Route
resource "aws_route" "example" {
  route_table_id         = aws_vpc.awsec2demo.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example.id
}

output "ec2_instance_id" {
  value = aws_instance.awsec2demo.id
}

output "public_ip" {
  value = aws_eip.awsec2demo_eip.public_ip
}
