resource "aws_vpc" "main" {
  cidr_block = "172.24.0.0/16"
}

resource "aws_subnet" "public" {
  count = length(var.azs)

  vpc_id            = aws_vpc.main.id
  availability_zone = var.azs[count.index]
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  tags = {
    Name = format("%s-%s", var.environment, var.azs[count.index])
    az   = var.azs[count.index]
  }
}
