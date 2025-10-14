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

resource "aws_security_group" "pet-sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.pet-vpc.id
  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
    security_group_id = aws_security_group.pet-sg.id
    cidr_ipv4         = var.my_ip
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
    security_group_id = aws_security_group.pet-sg.id
    cidr_ipv4         = var.my_ip
    from_port         = 80
    ip_protocol       = "tcp"
    to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
    security_group_id = aws_security_group.pet-sg.id
    cidr_ipv4         = var.my_ip
    from_port         = 443
    ip_protocol       = "tcp"
    to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.pet-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_instance" "pet-server" {
    ami                         = var.ami_id
    instance_type               = var.instance_type
    subnet_id                   = aws_subnet.pet-subnet.id
    vpc_security_group_ids      = [aws_security_group.pet-sg.id]
    availability_zone           = var.avail_zone
    associate_public_ip_address = true
    key_name                    = var.key_name
    tags = {
        Name = "pet-server"
    }
}