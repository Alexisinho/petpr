provider "aws" {
    region = "eu-central-1"
}

resource "aws_vpc" "pet-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "pet-vpc"
  }
}

resource "aws_subnet" "pet-subnet" {
    vpc_id = aws_vpc.pet-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "pet-subnet"
    }
}

resource "aws_internet_gateway" "pet-igw" {
  vpc_id = aws_vpc.pet-vpc.id
  tags = {
    Name = "pet-igw"
  }
}

resource "aws_route_table" "pet-rt" {
    vpc_id = aws_vpc.pet-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.pet-igw.id
    }
    tags = {
        Name = "pet-main-rt"
    }
}   

resource "aws_route_table_association" "pet-rt-assoc" {
  subnet_id      = aws_subnet.pet-subnet.id
  route_table_id = aws_route_table.pet-rt.id
}

resource "aws_security_group" "pet-sg"  {
    vpc_id = aws_vpc.pet-vpc.id
    ingress {
        description = "Allow SSH from my IP"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.my_ip]
    }
    ingress {
        description = "Allow HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Allow HTTPS"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "pet-server" {
    ami                         = "ami-08697da0e8d9f59ec" 
    instance_type               = "t3.micro"
    subnet_id                   = aws_subnet.pet-subnet.id
    vpc_security_group_ids      = [aws_security_group.pet-sg.id]
    availability_zone           = var.avail_zone
    associate_public_ip_address = true
    key_name                    = var.key_name
    tags = {
        Name = "pet-server"
    }
}