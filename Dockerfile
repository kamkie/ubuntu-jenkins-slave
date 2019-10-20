FROM ubuntu

RUN apt update && \
    apt -y  install software-properties-common && \
    add-apt-repository -y ppa:projectatomic/ppa && \
    apt update && \
    apt -y install podman && \
    sudo curl https://raw.githubusercontent.com/projectatomic/registries/master/registries.fedora -o /etc/containers/registries.conf && \
    sudo curl https://raw.githubusercontent.com/containers/skopeo/master/default-policy.json -o /etc/containers/policy.json

ADD entrypoint.sh /entrypoint.sh
CMD /entrypoint.sh
