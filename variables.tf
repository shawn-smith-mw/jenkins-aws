variable "profile" {
  type    = string
  default = "default"
}

variable "region-master" {
  type    = string
  default = "us-east-1"
}

variable "region-worker" {
  type    = string
  default = "us-west-2"
}

variable "cidr-block-master" {
  type    = string
  default = "10.17.0.0/16"
}

variable "cidr-block-worker" {
  type    = string
  default = "10.18.0.0/16"
}

variable "cidr-block-master-subnet-1" {
  type    = string
  default = "10.17.0.0/24"
}

variable "cidr-block-master-subnet-2" {
  type    = string
  default = "10.17.1.0/24"
}

variable "cidr-block-worker-subnet-1" {
  type    = string
  default = "10.18.0.0/24"
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "workers_count" {
  type    = number
  default = 1
}