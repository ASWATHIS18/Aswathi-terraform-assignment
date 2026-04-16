module "networking" {
  source = "./modules/networking"
}

module "ssh_key" {
  source = "./modules/ssh-key"
}

module "ec2_instance" {
  source = "./modules/ec2"

  vpc_id         = module.networking.vpc_id
  public_subnet  = module.networking.public_subnet
  private_subnet = module.networking.private_subnet
  key_name       = module.ssh_key.key_name

  ami_id        = var.ami_id
  instance_type = var.instance_type
}
