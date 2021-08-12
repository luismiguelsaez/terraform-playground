module "web_instance" {
  source         = "../../ec2/public-instance"
  vpc_id         = "vpc-0923724dbb0eefcbd"
  subnet_id      = "subnet-0345b82af5d72c35d" # Public subnet
  user_data_path = "./user-data.sh"
}

output "instance_public_ip" {
  value = module.web_instance.instance_public_ip
}