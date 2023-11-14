#!bin/bash

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get -y install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

#install latest version
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#add current user or ubuntu to the docker group on the instance
sudo usermod -aG docker

sudo apt update

#download java runtime environment for jenkins agent
sudo apt install -y default-jre

#installs ability to install, update, remove, and manage packages/ y for yes/ able to use apt for adding python dependencies
sudo apt install -y software-properties-common

#downloads updated versions of python 
sudo add-apt-repository -y ppa:deadsnakes/ppa

#install python version
sudo apt install -y python3.7

#install python virtual environment
sudo apt install -y python3.7-venv

#installs essential build tools
sudo apt install -y build-essential

#installs the MySQL client library files
sudo apt install -y libmysqlclient-dev

#installs Python 3.7 files for app development
sudo apt install -y python3.7-dev

#upgrade installed packages
sudo apt upgrade
