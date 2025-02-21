region             = "us-east-1"
vpc_cidr          = "10.0.0.0/16"
subnet_cidr       = "10.0.1.0/24"
ecr_repo_name     = "mcrp-api-image-repo-test"
security_group_name = "mcrp-hello-ecs-sg"
ecs_cluster_name   = "mcrp-api-ecs-cluster"
ami_id             = "ami-053a45fff0a704a47"
instance_type      = "t3.small"

env_vars = {
  "/backend/api_key"      = "CloudNexus-UI-Key1"
  "/backend/secret_token" = "nkdMCXJOJNZfSRYGdut9S5tcEOm0aFiEJaVktDkX"
}
