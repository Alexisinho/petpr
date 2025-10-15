variable avail_zone {
    description = "Availability zone for the EC2 instance"
    type        = string
    default = "eu-central-1a"
}

variable availability_zones {
    description = "Availability zones for vpc and subnet"
    type        = list
    default = ["eu-central-1a"]
}

variable subnet_cidr_block {
    description = "CIDR block for the subnet"
    type        = list
    default = ["10.0.10.0/24"]
}

variable "vpc_cidr_block" {
    description = "CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable public_key_path {
    description = "Path to the public SSH key for EC2 access"
    type        = string
    default = "C:/Users/37544/.ssh/myapp_key.pub"
}

variable private_key_location {
    description = "Local path to the private SSH key"
    type        = string
    default = "C:/Users/37544/.ssh/latest.pem"
}

variable default_route_table_id {
    description = "ID of the default VPC route table"
    type        = string
    default = "rtb-02a56bfa20bd08364"
}

variable key_name {
    description = "Name of the SSH key registered in AWS"
    type        = string
    default = "latest"
}

variable my_ip {
    description = "Your public IP address for restricted access"
    type        = string
    default = "0.0.0.0/0"
}

variable ami_id {
    description = "AMI ID for the EC2 instance"
    type        = string
    default = "ami-08697da0e8d9f59ec"
} 

variable instance_type {
    description = "EC2 instance type"
    type        = string
    default = "t3.micro"
}

