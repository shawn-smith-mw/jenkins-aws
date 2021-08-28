resource "aws_vpc" "vpc_master" {
  provider             = aws.region-master
  cidr_block           = var.cidr-block-master
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name      = "shawn-jenkins-vpc-master"
    Terraform = true
    Env       = "dev"
  }
}

resource "aws_vpc" "vpc_worker" {
  provider             = aws.region-worker
  cidr_block           = var.cidr-block-worker
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name      = "shawn-jenkins-vpc-worker"
    Terraform = true
    Env       = "dev"
  }
}

resource "aws_internet_gateway" "igw-master" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
  tags = {
    Terraform = true
    Env       = "dev"
  }
}

resource "aws_internet_gateway" "igw-worker" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_worker.id
  tags = {
    Terraform = true
    Env       = "dev"
  }
}

data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state    = "available"
}

resource "aws_subnet" "subnet_master_1" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = var.cidr-block-master-subnet-1
  tags = {
    Name      = "jenkins-subnet-master-1"
    Terraform = true
    Env       = "dev"
  }
}

resource "aws_subnet" "subnet_master_2" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = var.cidr-block-master-subnet-2
  tags = {
    Name      = "jenkins-subnet-master-2"
    Terraform = true
    Env       = "dev"
  }
}

data "aws_availability_zones" "worker-azs" {
  provider = aws.region-worker
  state    = "available"
}

resource "aws_subnet" "subnet_worker_1" {
  provider          = aws.region-worker
  availability_zone = element(data.aws_availability_zones.worker-azs.names, 0)
  vpc_id            = aws_vpc.vpc_worker.id
  cidr_block        = var.cidr-block-worker-subnet-1
  tags = {
    Name      = "jenkins-subnet-worker-1"
    Terraform = true
    Env       = "dev"
  }
}

resource "aws_vpc_peering_connection" "useast1-uswest2" {
  provider    = aws.region-master
  peer_vpc_id = aws_vpc.vpc_worker.id
  vpc_id      = aws_vpc.vpc_master.id
  peer_region = var.region-worker
  tags = {
    Terraform = true
    Env       = "dev"
  }
}

resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.region-worker
  vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  auto_accept               = true
}

resource "aws_route_table" "internet_route" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-master.id
  }
  route {
    cidr_block                = var.cidr-block-worker
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  }
  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name      = "masterRT"
    Terraform = true
    Env       = "dev"
  }
}

resource "aws_main_route_table_association" "set-master-default-rt-association" {
  provider       = aws.region-master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route.id
}

resource "aws_route_table" "internet_route_worker" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_worker.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-worker.id
  }
  route {
    cidr_block                = var.cidr-block-master
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  }
  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name      = "workerRT"
    Terraform = true
    Env       = "dev"
  }
}

resource "aws_main_route_table_association" "set-worker-default-rt-association" {
  provider       = aws.region-worker
  vpc_id         = aws_vpc.vpc_worker.id
  route_table_id = aws_route_table.internet_route_worker.id
}
