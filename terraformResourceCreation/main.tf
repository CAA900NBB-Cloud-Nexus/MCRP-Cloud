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

### **Security Group (Allow SSH, HTTP, and Backend Traffic)**
resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (CHANGE for security)
  }

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

### **ECS Cluster**
resource "aws_ecs_cluster" "backend_cluster" {
  name = var.ecs_cluster_name
}

### **Use Existing IAM Role for ECS Task Execution (`ecsTaskExecutionRole`)**
data "aws_iam_role" "ecs_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = data.aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

### **Use Existing IAM Role for EC2**
data "aws_iam_role" "ec2_role" {
  name = "ec2-backend-role"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-backend-instance-profile"
  role = data.aws_iam_role.ec2_role.name
}

### **Attach IAM Policies for EC2**
resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = data.aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = data.aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

### **Store Environment Variables in AWS SSM**
resource "aws_ssm_parameter" "env_vars" {
  for_each = var.env_vars

  name  = each.key
  type  = "SecureString"
  value = each.value
}

### **Use Existing SSH Key Pair (If Available)**
data "aws_key_pair" "existing_key" {
  key_name = "mcrp-ec2-key"
}

### **EC2 Instance**
resource "aws_instance" "backend_client" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = data.aws_key_pair.existing_key.key_name

  tags = {
    Name = "backend-client"
  }
}
