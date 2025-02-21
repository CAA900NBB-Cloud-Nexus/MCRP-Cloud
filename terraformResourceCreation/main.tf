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
