terraform{
  backend "s3" {
    bucket = "alexich-pet-s3"    
    key    = "prod/terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "pet-demo-dynamodb"
    encrypt = true
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.4.0"

  name = "pet-vpc"
  cidr = var.vpc_cidr_block

  azs             = var.availability_zones
  public_subnets  = var.pub_subnet_cidr_block
  private_subnets = var.priv_subnet_cidr_block

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Project   = "pet-app"
  }
}

module "alb-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"
  name = "alb-sg"
  description = "Security group for ALB"
  vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_alb" {
    security_group_id = module.alb-security-group.security_group_id
    cidr_ipv4         = var.my_ip
    from_port         = 80
    ip_protocol       = "tcp"
    to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_alb" {
  security_group_id = module.alb-security-group.security_group_id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

module "asg-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"
  name = "asg-sg"
  description = "Security group for ASG"
  vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_alb_traffic" {
    security_group_id = module.asg-security-group.security_group_id
    referenced_security_group_id = module.alb-security-group.security_group_id
    from_port         = 80
    ip_protocol       = "tcp"
    to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
    security_group_id = module.asg-security-group.security_group_id
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = module.asg-security-group.security_group_id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.3.0"
  name    = "pet-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  security_groups = [module.alb-security-group.security_group_id]

  listeners = {
    http = {
      port               = 80
      protocol           = "HTTP"
      forward = {
        target_group_key = "asg-target-group"
      }
    }
  }

  target_groups = {
    asg-target-group = {
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      create_attachment = false
      health_check = {
        path           = "/"
      }
    }  
  }
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"
  version = "9.0.0"
  name = "pet-asg"

  min_size = 1
  max_size = 3
  desired_capacity = 2
  vpc_zone_identifier = module.vpc.public_subnets  # Changed from private to public
  
  traffic_source_attachments = {
    alb = {
      traffic_source_identifier = module.alb.target_groups["asg-target-group"].arn
    }
  }

  image_id        = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  
  # Enable public IP for instances in public subnets
  network_interfaces = [{
    associate_public_ip_address = true
    delete_on_termination      = true
    device_index              = 0
    security_groups = [module.asg-security-group.security_group_id]
  }]

  tags = {
     Project     = "pet-app"
  }
}

#resource "aws_instance" "pet-server" {
#    ami                         = var.ami_id
#    instance_type               = var.instance_type
#   subnet_id                   = module.vpc.public_subnets[0]
#    vpc_security_group_ids      = [aws_security_group.pet-sg.id]
#    availability_zone           = var.avail_zone
#    associate_public_ip_address = true
#    key_name                    = var.key_name
#    tags = {
#        Name = "pet-server"
#    }
#}