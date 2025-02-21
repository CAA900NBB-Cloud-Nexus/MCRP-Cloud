variable "region" {
  description = "AWS Region"
}

variable "ecr_repo_name_ui" {
  description = "Name of the Frontend ECR repository"
}

variable "ecs_cluster_name_ui" {
  description = "Name of the Frontend ECS cluster"
}

variable "vpc_id" {
  description = "ID of the existing VPC where backend is deployed"
}

variable "subnet_id" {
  description = "ID of the existing subnet to use for frontend ECS"
}

variable "security_group_id" {
  description = "ID of the existing security group"
}
