#!/bin/bash


IP=$(hostname -I | awk '{print $1}')

RED='\033[1;31m' # Red Color
GREEN='\033[1;32m' # Green Color
NC='\033[0m' # No Color

#------------------------ install gitlab locally -------------------------------
sudo curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
sudo EXTERNAL_URL="http://$IP" apt-get install gitlab-ee
sudo printf "prometheus_monitoring['enable'] = false\ngrafana['enable'] = false\n" >> /etc/gitlab/gitlab.rb
sudo gitlab-ctl reconfigure
printf "Username: root\n" > /home/${SUDO_USER}/git-credentiels.txt && \
sudo cat /etc/gitlab/initial_root_password | grep -v "#" | grep "\S" >> /home/${SUDO_USER}/git-credentiels.txt
printf "################## go to $IP and coonect using ########################\n"
sudo cat /home/${SUDO_USER}/git-credentiels.txt
printf "#######################################################################\n"
printf "username and password saved in ~/git-credentiels.txt\n"
printf $IP
printf "END - installing gitlab - \n"
#-------------------------------------------------------------------------------
