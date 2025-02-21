provider "aws" {
  region = var.region
}

### **Retrieve AWS Credentials from SSM**
data "aws_ssm_parameter" "api_key" {
  name            = "/backend/api_key"
  with_decryption = true
}

data "aws_ssm_parameter" "secret_token" {
  name            = "/backend/secret_token"
  with_decryption = true
}

### **VPC Setup**
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

### **Security Group for Backend (Restricting Traffic)**
resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow backend app traffic
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### **ECR Repository**
resource "aws_ecr_repository" "backend_repo" {
  name = var.ecr_repo_name
}

### **ECS Cluster for Running Containers**
resource "aws_ecs_cluster" "backend_cluster" {
  name = var.ecs_cluster_name
}

### **IAM Role for ECS Execution**
data "aws_iam_role" "ecs_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = data.aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

### **Storing Environment Variables in AWS SSM**
resource "aws_ssm_parameter" "env_vars" {
  for_each = var.env_vars

  name  = each.key
  type  = "SecureString"
  value = each.value
}
