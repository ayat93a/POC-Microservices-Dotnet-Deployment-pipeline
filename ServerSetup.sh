#!/bin/bash
# HOW TO RUN THIS
# sudo nano ServerSetup.sh 
# paste the content of this SCRIPT
# sudo chmod +744 ServerSetup.sh
# sudo mv ServerSetup.sh /usr/local/bin 
# type ServerSetup.sh
# Or
# nano ~/.bashrc
# export PATH="$HOME/POC-Deploy-Microservices-Dotnet:$PATH"
# source ~/.bashrc
# type ServerSetup.sh

echo "install SSH"
sudo apt-get update
sudo apt install openssh-server
sudo systemctl start ssh
sudo systemctl enable ssh

echo "Install Nginx"
sudo apt update
sudo apt install nginx
sudo systemctl status nginx
sudo systemctl enable nginx

echo "Install .NET SDK 7.0"

sudo apt-get update && sudo apt-get install -y dotnet-sdk-7.0

echo "Update the www aowner"
sudo chown $USER:$USER /var/www

echo "Install Docker"
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl start docker
sudo systemctl enable docker
sudo apt-get -y install docker-compose
sudo groupadd docker
sudo usermod -aG docker $USER
sudo reboot
