output "ecr_repository_url_frontend" {
  value = aws_ecr_repository.frontend_repo.repository_url
}

output "frontend_ecs_cluster_name" {
  value = aws_ecs_cluster.frontend_cluster.name
}
