#!/bin/bash

if [[ -f /etc/.initialized ]]; then
  exit
fi

##
## Get everything up-to-date first
##
export DEBIAN_FRONTEND=noninteractive
apt update
apt -y upgrade
apt -y install pkg-config jq net-tools docker.io python3.8-venv
apt -y autoremove
snap install ngrok

##
## Install krew
##
export KREW_ROOT=/usr/local/krew
(
  set -x; TEMP_INST_DIR="$(mktemp -d)" && cd ${TEMP_INST_DIR} &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
  cd /
  /bin/rm -rf ${TEMP_INST_DIR}
  chmod -R og+rx /usr/local/krew/store
)

##
## Remind users at login to set up krew
##
cat >/etc/update-motd.d/99-rasa<<MYEOF
#!/bin/bash
GREEN=\$(tput setaf 2)
REV=\$(tput rev)
RESET=\$(tput sgr0)
printf "\${GREEN}\${REV}Download the helper script:\${RESET}\\n"
printf "curl -so k8s-helper.sh -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/k8s-helper\n\n"
printf "\${GREEN}\${REV}And then run it:\${RESET} chmod +x k8s-helper.sh && ./k8s-helper.sh\n\n"
printf "\${GREEN}\${REV}To have it also install REI run it as:\${RESET} chmod +x k8s-helper.sh && ./k8s-helper.sh rei\n\n"
MYEOF
chmod 755 /etc/update-motd.d/99-rasa

##
## Install bash completion helpers
##
COMPDIR=$(pkg-config --variable=completionsdir bash-completion)
TEMP_COMP_DIR=$(mktemp -d)
cd ${TEMP_COMP_DIR}
wget -O kubectx https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubectx.bash && cp kubectx ${COMPDIR}/
wget -O kubens https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubens.bash && cp kubens ${COMPDIR}/
cd /
/bin/rm -rf ${TEMP_COMP_DIR}

##
## Mark this this as complete
##
touch /etc/.initialized

##
## Reboot after 2 minutes to allow other first-time boot things to happen
##
shutdown -r +2
