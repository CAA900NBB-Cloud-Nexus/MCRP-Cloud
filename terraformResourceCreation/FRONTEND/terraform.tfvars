region             = "us-east-1"
ecr_repo_name_ui  = "mcrp-ui-image-repo"
ecs_cluster_name_ui  = "mcrp-ui-ecs-cluster"

# Use the same network as backend
vpc_id             = "10.0.0.0/16"
subnet_id          = "10.0.1.0/24"
security_group_id  = "mcrp-hello-ecs-sg"
