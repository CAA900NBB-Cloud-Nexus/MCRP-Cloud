variable "security_group_name" {
  description = "Security Group for Backend"
  default     = "mcrp-hello-ecs-sg"
}

variable "region" {
  description = "AWS Region"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
}

variable "env_vars" {
  description = "Environment variables stored in AWS SSM"
  type        = map(string)
  default     = {
    "/backend/api_key"      = "CloudNexus-UI-Key1"
    "/backend/secret_token" = "nkdMCXJOJNZfSRYGdut9S5tcEOm0aFiEJaVktDkX"
  }
}