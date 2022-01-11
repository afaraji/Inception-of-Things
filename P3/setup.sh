#!/bin/bash

#USER=afaraji
#RHOST=10.12.100.236
#ssh-copy-id USER@RHOST

RED='\033[1;31m' # Red Color
GREEN='\033[1;32m' # Green Color
NC='\033[0m' # No Color
sudo apt update
sudo apt install -y -qq net-tools
sudo apt install -y -qq curl
sudo apt install -y -qq vim


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
echo 'alias k=kubectl' >> ~/.bashrc
echo 'alias k="sudo kubectl"' >> /home/afaraji/.bashrc

# K3d
echo -e "${GREEN}---- Installing K3d ----${NC}"
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
k3d version | grep version && echo -e "${GREEN}[INFO] K3d installed successful${NC}" || echo -e "${RED}[INFO] error installing K3d${NC}"

# cluster configuration
echo -e "${GREEN}=====================================================${NC}"
echo -e "part 1 in the installation is done\n    start configuring the cluster ? [y/n]"
read ANSWER
if [ $ANSWER != 'y' ]
then
	exit
fi
############### argoCD install  #################

sudo k3d cluster create dev-cluster --port 8080:80@loadbalancer --port 8888:8888@loadbalancer
sudo kubectl create namespace argocd
#sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# ---> expose argoCD API Server by Changing the argocd-server service type to LoadBalancer
#sudo kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
# ---> xpose argoCD by ingres conf
#sudo wget https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.1/manifests/install.yaml

sudo kubectl apply -n argocd -f conf/install_argocd.yaml
sudo kubectl apply -n argocd -f conf/ingress_argocd.yaml
while true
do
	sudo kubectl get pods -n argocd | tail -n +2 | awk '{print $3}' | grep -v "Running"
	if [ $? == 0 ]; then
		break
	else
		echo "WAITING for argoCD..."
	fi
	sleep 1
done
###########check url: https://stackoverflow.com/questions/44140593/how-to-run-command-after-initialization ##########
#lifecycle:
#            postStart:
#              exec:
#                command: ["/bin/sh", "-c", {{cmd}}]
##################3
printf "${RED}###############################################\n"
printf "connect on port 8080/argocd\n"
printf "${GREEN}your credentiels are:${NC} admin:$(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)\n"

sudo kubectl apply -n argocd -f conf/app_argocd.yaml
printf "${GREEN}################### DONE ######################${NC}\n"
