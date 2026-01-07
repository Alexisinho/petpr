output "vpc_id" {
    value = module.vpc.vpc_id
}

output "public_subnets" {
    value = module.vpc.public_subnets
}

output "alb_dns_name" {
    description = "DNS name of the Application Load Balancer - use this to access your app"
    value = module.alb.dns_name
}

output "application_url" {
    description = "URL to access your Flask Calculator"
    value = "http://${module.alb.dns_name}"
}

#output "ec2_public_ip" {
#    value = aws_instance.pet-server.public_ip
#}