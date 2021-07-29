variable "ami" {
  type = object({
    name                = string
    virtualization_type = string
    owners              = list(string)
  })
  default = {
    name                = "amzn2-ami-hvm-2.0.????????.?-x86_64-gp2"
    virtualization_type = "hvm"
    owners              = ["137112412989"] # Amazon
  }
}