# resource "aws_s3_bucket" "s3_bucket" {
#   bucket = "terraform-statefile-learnine12" # change this
# }

# resource "aws_dynamodb_table" "terraform_lock" {
#   name           = "terraform-lock-learnnine12"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./Modules/network"
  name   = var.project_name
  cidr   = "10.0.0.0/16"
  azs    = ["us-east-1a", "us-east-1b"]
}

module "ecs" {
  source              = "./Modules/ecs"
  cluster_name        = "${var.project_name}-cluster"
  alb_subnets         = module.network.public_subnets
  service_subnets     = module.network.private_subnets
  vpc_id              = module.network.vpc_id
  container_definitions = [
    {
      name         = "patient-service"

      container_port = 3000
      path          = "/patient"
      image         = "patient-service:latest"
    },
    {
      name         = "appointment-service"
      container_port = 3001
      path          = "/appointment"
      image         = "appointment-service:latest"
    }
  ]
}
