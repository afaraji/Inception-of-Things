#!/bin/bash

#USER=afaraji
#RHOST=10.12.100.236
#ssh-copy-id USER@RHOST

RED='\033[1;31m' # Red Color
GREEN='\033[1;32m' # Green Color
NC='\033[0m' # No Color
sudo apt update
sudo apt install -y net-tools
sudo apt install -y curl
sudo apt install -y vim


# install docker

echo -e "${GREEN}---- Installing docker ----${NC}"
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker
docker ps && echo -e "${GREEN}[INFO] Docker installed successful${NC}" || echo -e "${RED}[INFO] Docker installing kubectl${NC}"

# kubectl
echo -e "${GREEN}---- Installing Kubectl ----${NC}"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && echo -e "${GREEN}[INFO] kubectl installed successful${NC}" || echo -e "${RED}[INFO] error installing kubectl${NC}"
echo 'alias k=kubectl' >>~/.bashrc

# K3d
echo -e "${GREEN}---- Installing K3d ----${NC}"
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
k3d version | grep version && echo -e "${GREEN}[INFO] K3d installed successful${NC}" || echo -e "${RED}[INFO] error installing K3d${NC}"

# cluster configuration
echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN}part 1 in the installation is done\n    start configuring the cluster ? [y/n] ${NC}"
read ANSWER
if [ ANSWER != 'y' ]
then
	exit
fi
