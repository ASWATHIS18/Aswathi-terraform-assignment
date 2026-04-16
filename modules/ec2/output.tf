output "public_ip" {
  value = aws_instance.public_vm.public_ip
}

output "private_ip" {
  value = aws_instance.private_vm.private_ip
}