provider "aws" {
  region = var.region
}

### **ECR Repository for Frontend**
resource "aws_ecr_repository" "frontend_repo" {
  name = var.ecr_repo_name_ui
}

### **ECS Cluster for Frontend**
resource "aws_ecs_cluster" "frontend_cluster" {
  name = var.ecs_cluster_name_ui
}

### **Associate Frontend ECS with the Existing Backend Network**
data "aws_vpc" "existing_vpc" {
  id = var.vpc_id  # Use existing VPC where backend is deployed
}

data "aws_subnet" "existing_subnet" {
  id = var.subnet_id  # Use existing subnet
}

data "aws_security_group" "existing_sg" {
  id = var.security_group_id  # Use existing security group
}
