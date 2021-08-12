module "web_instance" {
  source         = "../../ec2/public-instance"
  vpc_id         = "vpc-0923724dbb0eefcbd"
  subnet_id      = "subnet-0e8a75f17e497d808"
  user_data_path = "./user-data.sh"
}