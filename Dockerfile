from debian:sid

run  export DEBIAN_FRONTEND=noninteractive \
 &&  echo "deb http://httpredir.debian.org/debian experimental main" >> /etc/apt/sources.list \
 &&  apt-get update \
 &&  apt-get install -y -t experimental virt-manager libgl1-mesa-dri libgl1-mesa-glx openssh-client ssh-askpass socat \
 &&  apt-get clean \
 &&  rm -rf /var/lib/apt/lists

add docker-entrypoint.sh /usr/local/bin/virt-manager
entrypoint ["virt-manager"]
