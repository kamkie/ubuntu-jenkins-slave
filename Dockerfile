FROM ubuntu:20.10

RUN apt update && \
    apt upgrade -y && \
    apt install -y software-properties-common sudo curl wget vim dumb-init iproute2 zip unzip screenfetch && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9 && \
    apt clean all

RUN wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz && \
    tar -xf openshift-client-linux.tar.gz -C /usr/sbin

RUN mkdir /home/jenkins
ENV HOME /home/jenkins
WORKDIR /home/jenkins
RUN chown -R 1001:0 $HOME && \
    chmod -R g+rw $HOME && \
    useradd -u 1001 jenkins && \
    usermod -aG sudo jenkins && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN apt-add-repository 'deb http://repos.azulsystems.com/ubuntu stable main' && \
    apt update && \
    apt install -y zulu-11 && \
    apt clean all

RUN curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt update && \
    apt install -y nodejs && \
    apt clean all

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable" && \
    apt install -y docker-ce docker-ce-cli containerd.io && \
    apt clean all

#RUN apt update && \
#    apt install -y podman fuse-overlayfs nftables && \
#    curl https://raw.githubusercontent.com/projectatomic/registries/master/registries.fedora -o /etc/containers/registries.conf && \
#    curl https://raw.githubusercontent.com/containers/skopeo/master/default-policy.json -o /etc/containers/policy.json && \
#    apt clean all

RUN apt-add-repository "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.10 /"  && \
    sh -c 'curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.10/Release.key | sudo apt-key add -' && \
    apt update && \
    apt -y install podman fuse-overlayfs nftables

RUN rm -rf /var/lib/shared/overlay-images && \
    rm -rf /var/lib/shared/overlay-layers && \
    rm -rf /var/lib/shared/overlay-images/images.lock /var/lib/shared/overlay-layers/layers.lock && \
    rm -f /etc/containers/storage.conf

RUN apt update && \
    apt upgrade -y

RUN docker --version && podman --version

ADD entrypoint.sh /entrypoint.sh
ADD daemon.json /etc/docker/daemon.json
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint.sh"]
