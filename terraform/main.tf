# ECR Repositories
data "aws_ecr_repository" "reverse_proxy" {
  name = format("reverse-proxy-%s", lower(var.project_id))
}

data "aws_ecr_repository" "users_microservice" {
  name = format("users-microservice-%s", lower(var.project_id))
}

data "aws_ecr_repository" "flights_microservice" {
  name = format("flights-microservice-%s", lower(var.project_id))
}

data "aws_ecr_repository" "bookings_microservice" {
  name = format("bookings-microservice-%s", lower(var.project_id))
}

# Key/Value pairs of root db creds, microservice user creds, and the JWT secret
data "aws_secretsmanager_secret_version" "default" {
  secret_id = "${var.environment}/${var.project_id}/default"
}
locals {
  secrets = jsondecode(
    data.aws_secretsmanager_secret_version.default.secret_string
  )
  vpc_cidr_block = "10.6.0.0/16"
}

# Creates a private & public subnet per availability zone of the region
module "networks" {
  source         = "./modules/networks"
  vpc_cidr_block = local.vpc_cidr_block
  rt_cidr_block  = "0.0.0.0/0"
  project_id     = var.project_id
}

# RDS instance
module "rds" {
  source     = "./modules/rds"
  vpc        = {
    id         = module.networks.vpc_id
    cidr_block = local.vpc_cidr_block
  }
  subnet_ids = module.networks.private_subnet_ids
  project_id = var.project_id
}
## Bastion host on public subnet that initially connects to RDS instance to create schema and add the microservice user

#data "aws_iam_policy" "read_s3" {
#  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
#}
#
#module "bastion" {
#  source         = "./modules/bastion"
#  policy_arn     = data.aws_iam_policy.read_s3.arn
#  instance_type  = "t2.micro"
#  vpc_id         = module.networks.vpc_id
#  public_ssh_key = var.public_ssh_key
#  subnet_id      = element(module.networks.public_subnet_ids, 1)
#  user_data      = templatefile("${path.root}/user_data.sh", {
#    s3_bucket        = lower(var.project_id)
#    db_host          = module.rds.instance_address
#    db_root_username = local.secrets.db_root_username
#    db_root_password = local.secrets.db_root_password
#    db_username      = local.secrets.db_username
#    db_password      = local.secrets.db_password
#  })
#
#  project_id = var.project_id
#}
