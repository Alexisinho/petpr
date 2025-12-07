#  backend "s3" {
# 1. Имя бакета, который ты создал руками
#    bucket = "my-pet-project-tf-state-2025"    
# 2. Путь к файлу внутри бакета (как папки)
#    key    = "prod/terraform.tfstate"
# 3. Твой регион
#    region = "eu-central-1"
# 4. Таблица для блокировок (которую создал руками)
#    dynamodb_table = "terraform-locks"
# 5. Шифрование файла стейта (безопасность)
#    encrypt = true
#  }
# ---------------------
#}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.4.0"

  name = "pet-vpc"
  cidr = var.vpc_cidr_block

  azs             = var.availability_zones
  public_subnets  = var.subnet_cidr_block

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
  }
}

resource "aws_security_group" "pet-sg" {
  name        = "pet-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = module.vpc.vpc_id
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

resource "aws_vpc_security_group_ingress_rule" "allow_prometheus" {
    security_group_id = aws_security_group.pet-sg.id
    cidr_ipv4         = var.my_ip
    from_port         = 9090
    ip_protocol       = "tcp"
    to_port           = 9090
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
    subnet_id                   = module.vpc.public_subnets[0]
    vpc_security_group_ids      = [aws_security_group.pet-sg.id]
    availability_zone           = var.avail_zone
    associate_public_ip_address = true
    key_name                    = var.key_name
    tags = {
        Name = "pet-server"
    }
}