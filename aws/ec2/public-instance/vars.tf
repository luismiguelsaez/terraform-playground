variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_size" {
  type    = string
  default = "t2.micro"
}

variable "ami" {
  type = object({
    name               = string
    virtualization_type = string
    owners             = list(string)
  })
  default = {
    name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    virtualization_type = "hvm"
    owners              = ["099720109477"] # Canonical
  }
}

variable "key_pair" {
  type = object({
    name       = string
    public_key = string
  })
  default = {
    name       = "public_instance_module_default"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGoy5fPfqOkOIGZs2nTga0lWBXzDuZVA5C+kD+qNTut8Z2WArr3buhRsS9bOlAxJUHAocTLmS2hI688jighAPGq4XSB6lDpwd1KId2MxdvFWk0rKHNtlYBHN0lh6fvwD/DCvR4+vvvK+1lgXUfrSzOYjIizHeYMHcmNWUHL6rRs3Ikpi9rd04FYNfSIZSj1vWvZAS2E4n+SijeyflayjwiQHaJ7001aLE3HIZSHVaLsfShkHe1/6nQOU7mLFBZGlDNSOlEH1SVDhLv/eL6J1b/kYtKzjhv9V7qrZW9raw9YUV4tDr5BmZAzMjET203Zjl1dJWVKK8PsqRGoLmTKiOj"
  }
}