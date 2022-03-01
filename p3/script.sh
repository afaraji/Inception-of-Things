#!/bin/bash

IP=$(hostname -I | awk '{print $1}')

RED='\033[1;31m' # Red Color
GREEN='\033[1;32m' # Green Color
NC='\033[0m' # No Color

# echo -e "${GREEN}---- Installing dependencies ----${NC}"
# sudo apt-get update -qq > /dev/null
# sudo apt-get install -y -qq net-tools curl vim wget git
# sudo apt-get install -y -qq openssh-server ca-certificates perl
# sudo systemctl disable apache2 && sudo systemctl stop apache2

# install docker

echo -e "${GREEN}---- Installing docker ----${NC}"
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker
sudo docker ps && echo -e "${GREEN}[INFO] Docker installed successful${NC}" || echo -e "${RED}[INFO] Error installing Docker${NC}"
sudo rm -rf get-docker.sh

# kubectl
echo -e "${GREEN}---- Installing Kubectl ----${NC}"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && echo -e "${GREEN}[INFO] kubectl installed successful${NC}" || echo -e "${RED}[INFO] error installing kubectl${NC}"
sudo rm -rf kubectl

# K3d
echo -e "${GREEN}---- Installing K3d ----${NC}"
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
k3d version | grep version && echo -e "${GREEN}[INFO] K3d installed successful${NC}" || echo -e "${RED}[INFO] error installing K3d${NC}"

# cluster configuration
echo -e "${GREEN}=====================================================${NC}"

############### creating cluster|exposing ports 8888->80 and 8888->8888 #################
echo -e "${GREEN}---- Creating dev-cluster ----${NC}"
#sudo k3d cluster create dev-cluster --port 8888:80@loadbalancer --port 8888:8888@loadbalancer --port 433:443@loadbalancer
sudo k3d cluster create dev-cluster --port 8888:80@loadbalancer
############### argoCD install  #################
echo -e "${GREEN}---- Installing argoCD ----${NC}"
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd
sudo kubectl create namespace argocd
# ---> xpose argoCD by ingres conf
#sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# ---> expose argoCD API Server by Changing the argocd-server service type to LoadBalancer
#sudo kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

sudo kubectl apply -n argocd -f confs/script-argocd.yaml
sudo kubectl apply -n argocd -f confs/ingress-argocd.yaml
printf "${GREEN}WAITING for argoCD...\n"
sudo kubectl -n argocd rollout status deployment argocd-server
printf "fetching user and password${NC}\n"

printf "${RED}###############################################${NC}\n"
#DEF_HOST=$(/usr/sbin/ifconfig enp0s3 | /usr/bin/grep broadcast | /usr/bin/awk '{print $2}')
printf "connect on${GREEN} ${IP}:8888/argocd${NC}\n\n"
printf "${RED}###############################################${NC}\n"
PASS=$(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
printf "USERNAME: ${GREEN}admin${NC}\nPASSWORD: ${GREEN}${PASS}${NC}\n"
printf "USERNAME: admin$\nPASSWORD: ${PASS}\n" > /home/${SUDO_USER}/argocd-credentiels.txt
printf "${RED}###############################################${NC}\n"

############### Deploying argoCD app  #################
echo -e "${GREEN}---- Deploying argoCD APP ----${NC}"
sudo kubectl apply -n argocd -f confs/app-argocd.yaml
printf "${GREEN}################### DONE ######################${NC}\n"

