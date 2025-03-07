# Install Docker Engine
Install-WindowsFeature -Name Containers -IncludeAllSubFeature -IncludeManagementTools
Start-Service Docker

# Install AWS CLI
Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "C:\AWSCLIV2.msi"
Start-Process msiexec.exe -ArgumentList "/i C:\AWSCLIV2.msi /quiet /norestart" -Wait

# Authenticate with AWS ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 970547375353.dkr.ecr.us-east-1.amazonaws.com

# Pull UI container
docker pull 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-ui-image-repo:latest

# Pull API container
docker pull 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-api-image-repo:latest

# Run UI container
docker run -d --name ui-container -p 80:80 --restart unless-stopped 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-ui-image-repo:latest

# Run API container
docker run -d --name api-container -p 3000:3000 --restart unless-stopped 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-api-image-repo:latest
