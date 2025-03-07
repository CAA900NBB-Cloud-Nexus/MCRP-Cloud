# Install Docker on Windows Server
Write-Output "Installing Docker..."
Install-WindowsFeature -Name Containers

# Install AWS CLI
Write-Output "Installing AWS CLI..."
Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "AWSCLIV2.msi"
Start-Process msiexec.exe -ArgumentList "/i AWSCLIV2.msi /quiet" -Wait

# Set AWS Credentials (Replace with your AWS keys)
Write-Output "Configuring AWS CLI..."
aws configure set aws_access_key_id AKIA6D6JBVT4VRT3MGHM
aws configure set aws_secret_access_key kjI+BuuqFEV0QMzOn4jMu3V6UhAdHk9FjtsdHMk9
aws configure set default.region us-east-1

# Authenticate Docker to AWS ECR
Write-Output "Authenticating Docker with AWS ECR..."
$ECR_LOGIN = aws ecr get-login-password --region us-east-1
docker login --username AWS --password-stdin 970547375353.dkr.ecr.us-east-1.amazonaws.com

# Pull Docker Image from AWS ECR
Write-Output "Pulling Docker Image from AWS ECR..."
docker pull 970547375353.dkr.ecr.us-east-1.amazonaws.com/YOUR_IMAGE_NAME:latest

# Run the Docker Container
Write-Output "Starting Docker Container..."
docker run -d -p 80:80 970547375353.dkr.ecr.us-east-1.amazonaws.com/YOUR_IMAGE_NAME:latest

Write-Output "Docker setup complete!"
