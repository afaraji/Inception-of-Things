#!/bin/bash


# show global config: sudo kubectl config view --raw
#1st enable Requests to the local network: Menu> Admin > Setting > Network > Outbound requests > Allow requests...

#deploy rbac
sudo kubectl apply -f ../confs/gitlab-rbac.yaml -n kube-system

# $> sudo kubectl cluster-info | grep -E 'Kubernetes master|Kubernetes control plane' | awk '/http/ {print $NF}'
# go to infrastructure > kuberenetes > connect to existing cluster
#get API url
echo "##################################################################"
echo "instruction to connect the cluster to gitlab are in ~/connect-cluster-gitlab.txt"
echo "##################################################################"

IP=$(hostname -I | awk '{print $1}')
API_PORT=$(sudo kubectl cluster-info | grep -E 'Kubernetes master|Kubernetes control plane' | awk -F: '{print $3}')
#get root CA certificat
CA_CERT=$(sudo kubectl config view --raw -o=jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode)

printf " *** instruction to connect the cluster to gitlab ***\n\n" > /home/${SUDO_USER}/connect-cluster-gitlab.txt
echo "API URL: https://${IP}:${API_PORT}" >> /home/${SUDO_USER}/connect-cluster-gitlab.txt
printf "CA Certificate:\n${CA_CERT}\n\n" >> /home/${SUDO_USER}/connect-cluster-gitlab.txt
SECRET=$(sudo kubectl -n kube-system get secret | grep gitlab | awk '{print $1}')
S_TOKEN=$(sudo kubectl -n kube-system get secret $SECRET -o jsonpath='{.data.token}' | base64 --decode)
printf "Service Token:(secret:${SECRET}):\n${S_TOKEN}\n\n" >> /home/${SUDO_USER}/connect-cluster-gitlab.txt

# $> sudo kubectl -n kube-system get secret | grep gitlab | awk '{print $1}'
# $> sudo kubectl -n kube-system describe secret gitlab-token-ft4r7
# $> sudo kubectl -n kube-system get secret gitlab-token-ft4r7 -o jsonpath='{.data.token}' | base64 --decode && echo

#install helm: source: https://helm.sh/docs/intro/install/
echo "##################################################################"
echo "	installing helm"
echo "##################################################################"
sudo curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm


#--------------------------
echo "##################################################################"
echo "	installing gitlab runner"
echo "##################################################################"
#install gitlab Runner: source:https://docs.gitlab.com/runner/install/kubernetes.html
sudo helm repo add gitlab https://charts.gitlab.io
sudo kubectl create ns gitlab
echo "go to project > settings > CI/CD > Runners"
echo "and add the IP and token to ~/confs/values.yaml"
echo "then use the command:"
echo "'sudo helm install --namespace gitlab gitlab-runner -f ../confs/values.yaml gitlab/gitlab-runner'"
#sudo helm install --namespace gitlab gitlab-runner -f values.yaml gitlab/gitlab-runner
