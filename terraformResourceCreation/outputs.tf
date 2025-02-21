output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.backend_repo.repository_url
}

output "security_group_id" {
  value = aws_security_group.backend_sg.id
}
output "iam_instance_profile" {
  value = aws_iam_instance_profile.ec2_profile.name
}
output "iam_role_name" {
  value = aws_iam_role.ec2_role.name
}
