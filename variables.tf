variable "region" {
  description = "It is the region where the resources will be created"
  type        = string
  default     = "ap-south-1"

}
variable "ami_id" {
  description = "It is the AMI ID of the EC2 instance"
  type        = string
  default     = "ami-05d2d839d4f73aafb"

}
variable "instance_type" {
  description = "It is the type of the EC2 instance"
  type        = string
  default     = "t3.micro"

}