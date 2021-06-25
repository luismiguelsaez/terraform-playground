# Global varibales

# We could use this variable to create ECS services dynamically
# At first, you could see a limitation when we're only able to define a container per ECS service
variable "ecs_services" {
  type = list(object({
    name = string
    image = string
    container_port = number
    host_port = number
    max_capacity = number
    min_capacity = number
    task_cpu = number
    task_mem = number
    container_cpu = number
    container_mem = number
  }))
  default = [
    {
      name = "web"
      image = "nginx:alpine"
      container_port = 80
      host_port = 80
      max_capacity = 4
      min_capacity = 1
      task_cpu = 256
      task_mem = 512
      container_cpu = 128
      container_mem = 256
    }
  ]
}

# VPC variables
variable "vpc_id" {}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

# ECS variables
# Service name definition
variable "service_name" {
  type = string
  default = "DummyCluster"
}

variable "service_desired_count" {
  type = number
  default = 2
}

variable "instance_type" {
  default = "m4.large"
}

variable "key_name" {
  default = "DummyCluster"
}

variable "cluster_min_size" {
  default = "2"
}

variable "cluster_max_size" {
  default = "2"
}

variable "cluster_name" {}
