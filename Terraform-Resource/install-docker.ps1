# Enable TLS 1.2 for secure downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Install Docker
Invoke-WebRequest -Uri "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -OutFile "C:\DockerDesktopInstaller.exe"
Start-Process "C:\DockerDesktopInstaller.exe" -ArgumentList "/quiet" -Wait

# Add Docker path
$env:Path += ";C:\Program Files\Docker\Docker\resources\bin"

# Install AWS CLI
Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "C:\AWSCLIV2.msi"
Start-Process msiexec.exe -ArgumentList "/i C:\AWSCLIV2.msi /quiet /norestart" -Wait

# Restart the machine to apply Docker installation
Restart-Computer -Force

# Wait for reboot
Start-Sleep -s 60

# Authenticate with AWS ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 970547375353.dkr.ecr.us-east-1.amazonaws.com

# Pull UI container from ECR
docker pull 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-ui-image-repo:latest

# Pull API container from ECR
docker pull 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-api-image-repo:latest

# Run UI container on localhost (Port 80)
docker run -d --name ui-container -p 80:80 --restart unless-stopped 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-ui-image-repo:latest

# Run API container on localhost (Port 3000)
docker run -d --name api-container -p 3000:3000 --restart unless-stopped 970547375353.dkr.ecr.us-east-1.amazonaws.com/mcrp-api-image-repo:latest
