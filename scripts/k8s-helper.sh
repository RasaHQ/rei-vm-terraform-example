#!/bin/bash

##
## This script is intented to help the user set up their initial k8s environment on a GCE VM
## and optionally install REI/rasactl
##
INSTALL_REI=false

if [[ $1 == *rei* ]]; then
  INSTALL_REI=true
fi

CHK_GROUPS=$(groups)
printf "Checking group membership: "
if [[ ! ${CHK_GROUPS} == *docker* ]]; then
    printf "FAIL\n"
    printf "Run: sudo usermod -a -G docker \${USER} && newgrp docker\n"
    printf "Then re-run this script.\n"
    exit
else
    printf "PASS\n"
fi

if [[ ${INSTALL_REI} == "true" ]]; then
  printf "Downloading the rei installer script and running it.\n"
  ##
  ## This will grab the latest REI installation script and run it
  ##
  curl -O https://rei.rasa.com/rei.sh && bash rei.sh -y
fi

printf "Checking PATH for krew: "
if [[ ${PATH} == *krew* ]]; then
    which kubectl-krew > /dev/null 2>&1
    if [[ $? -eq 1 ]]; then
        printf "FAIL\n"
        printf "Your PATH contains 'krew' but kubectl-krew cannot be found. Please resolve this issue.\n"
        exit
    else
        printf "PASS\n"
    fi
else
    printf "FAIL\n"
    grep -q .krew/bin ${HOME}/.bashrc
    if [[ $? -eq  0 ]]; then
        printf "You have krew in your bashrc but the currently running shell does not have krew in its PATH.\n"
        export PATH=${PATH}:/usr/local/krew/bin:${HOME}/.krew/bin
    else
        printf "Updating your PATH via your .bashrc with the following:\n"
        printf "export PATH=\"\${PATH}:/usr/local/krew/bin:\${HOME}/.krew/bin\" >> \${HOME}/.bashrc\n"
        echo 'export PATH=${PATH}:/usr/local/krew/bin:${HOME}/.krew/bin' >> ${HOME}/.bashrc
        export PATH=${PATH}:/usr/local/krew/bin:${HOME}/.krew/bin
    fi
    printf "You will want to source your .bashrc when this script finishes.\n"
fi

printf "Checking for kubectx installation: "
if [[ `which kubectl-ctx` == "" ]]; then
    printf "OK (not installed)\n"
    printf "Attempting to install kubectx:\n"
    kubectl krew install ctx
else
    printf "OK (already installed)\n"
fi

printf "Checking for kubens installation: "
if [[ `which kubectl-ns` == "" ]]; then
    printf "OK (not installed)\n"
    printf "Attempting to install kubens:\n"
    kubectl krew install ns
else
    printf "OK (already installed)\n"
fi

printf "Check (and updating) your .bashrc with k (kubectl), kns (kubens->kubectl-ns), and kubectx (kubectl-ctx)\n"
printf "aliases and tab completion for kubectl, kubens, kubectx, and helm\n"

if [[ ! `grep "helm completion" ${HOME}/.bashrc` ]]; then
    echo 'source <(helm completion bash)' >> ${HOME}/.bashrc
fi

if [[ ! `grep "kubectl completion" ${HOME}/.bashrc` ]]; then
    echo 'source <(kubectl completion bash)' >> ${HOME}/.bashrc
fi

if [[ ! `grep "alias k=" ${HOME}/.bashrc` ]]; then
    echo "alias k=kubectl" >> ${HOME}/.bashrc
fi

if [[ ! `grep "alias kns=" ${HOME}/.bashrc` ]]; then
    echo "alias kns=kubens" >> ${HOME}/.bashrc
fi

if [[ ! `grep __start_kubectl ${HOME}/.bashrc` ]]; then
    echo "complete -F __start_kubectl k" >> ${HOME}/.bashrc
fi

if [[ ! `grep "alias kubens" ${HOME}/.bashrc` ]]; then
    echo "alias kubens=kubectl-ns" >> ${HOME}/.bashrc
fi

if [[ ! `grep "alias kubectx" ${HOME}/.bashrc` ]]; then
    echo "alias kubectx=kubectl-ctx" >> ${HOME}/.bashrc
fi

if [[ ! `grep "alias kgp" ${HOME}/.bashrc` ]]; then
    echo "alias kgp='kubectl get pods'" >> ${HOME}/.bashrc
fi

if [[ ! `grep "alias kgd" ${HOME}/.bashrc` ]]; then
    echo "alias kgd='kubectl get deployments'" >> ${HOME}/.bashrc
fi

if [[ ! `grep "alias kgs" ${HOME}/.bashrc` ]]; then
    echo "alias kgs='kubectl get svc'" >> ${HOME}/.bashrc
fi

