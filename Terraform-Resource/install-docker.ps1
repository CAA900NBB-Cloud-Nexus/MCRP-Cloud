# Install Docker on Windows Server
Write-Output "Installing Docker..."
Install-WindowsFeature -Name Containers

# Install AWS CLI
Write-Output "Installing AWS CLI..."
Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "AWSCLIV2.msi"
Start-Process msiexec.exe -ArgumentList "/i AWSCLIV2.msi /quiet" -Wait

# Set AWS Credentials (Replace with your AWS keys)
Write-Output "Configuring AWS CLI..."
aws configure set aws_access_key_id YOUR_AWS_ACCESS_KEY
aws configure set aws_secret_access_key YOUR_AWS_SECRET_KEY
aws configure set default.region YOUR_AWS_REGION

# Authenticate Docker to AWS ECR
Write-Output "Authenticating Docker with AWS ECR..."
$ECR_LOGIN = aws ecr get-login-password --region YOUR_AWS_REGION
docker login --username AWS --password-stdin YOUR_AWS_ACCOUNT_ID.dkr.ecr.YOUR_AWS_REGION.amazonaws.com

# Pull Docker Image from AWS ECR
Write-Output "Pulling Docker Image from AWS ECR..."
docker pull YOUR_AWS_ACCOUNT_ID.dkr.ecr.YOUR_AWS_REGION.amazonaws.com/YOUR_IMAGE_NAME:latest

# Run the Docker Container
Write-Output "Starting Docker Container..."
docker run -d -p 80:80 YOUR_AWS_ACCOUNT_ID.dkr.ecr.YOUR_AWS_REGION.amazonaws.com/YOUR_IMAGE_NAME:latest

Write-Output "Docker setup complete!"
