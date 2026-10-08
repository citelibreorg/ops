#!/bin/bash
echo "+------------------------------+"
echo "|     Installing Minikube      |"
echo "+------------------------------+"
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

minikube version

## Install only for non maven deployment
#echo "+------------------------------+"
#echo "|     Installing Bundlebee     |"
#echo "+------------------------------+"
#curl -L https://yupiik.github.io/bundlebee/install/install.sh | bash
