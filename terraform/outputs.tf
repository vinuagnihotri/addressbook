output "ec2_public_ip"{
    value = module.myserver-instance.ec2.public_ip
}