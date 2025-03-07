# Install Docker on Windows Server
Write-Output "Installing Docker..."
Install-WindowsFeature -Name Containers

# Install AWS CLI
Write-Output "Installing AWS CLI..."
Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "AWSCLIV2.msi"
Start-Process msiexec.exe -ArgumentList "/i AWSCLIV2.msi /quiet" -Wait
Write-Output "AWS CLI Installed."

# Configure AWS CLI with Credentials (Replace with your actual credentials)
Write-Output "Configuring AWS CLI..."
aws configure set aws_access_key_id "AKIA6D6JBVT4VRT3MGHM"
aws configure set aws_secret_access_key "kjI+BuuqFEV0QMzOn4jMu3V6UhAdHk9FjtsdHMk9"
aws configure set default.region "us-east-1"  # Your ECR region

# Authenticate Docker with AWS ECR
Write-Output "Authenticating Docker with AWS ECR..."
$ECR_LOGIN = aws ecr get-login-password --region us-east-1
docker login --username AWS --password-stdin 970547375353.dkr.ecr.us-east-1.amazonaws.com

# Pull Docker Images from AWS ECR
Write-Output "Pulling Docker Images from AWS ECR..."
docker pull 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-api-image-repo:latest
docker pull 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-ui-image-repo:latest

# Run API Container
Write-Output "Starting API Container..."
docker run -d --name mcrp-api-container -p 5000:5000 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-api-image-repo:latest

# Run UI Container
Write-Output "Starting UI Container..."
docker run -d --name mcrp-ui-container -p 80:80 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-ui-image-repo:latest

Write-Output "Docker containers for API and UI are now running!"
