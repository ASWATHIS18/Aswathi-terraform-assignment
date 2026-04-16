output "public_ip" {
  value = module.ec2_instance.public_ip
}

output "private_ip" {
  value = module.ec2_instance.private_ip
}

output "ssh_private_key" {
  value     = module.ssh_key.private_key
  sensitive = true
}