FROM ubuntu:22.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common sudo curl wget vim dumb-init iproute2 zip unzip screenfetch fuse-overlayfs nftables gnupg ca-certificates && \
    apt-get clean all

RUN  sh -c 'curl -s https://repos.azul.com/azul-repo.key | sudo gpg --dearmor -o /usr/share/keyrings/azul.gpg' && \
    sh -c 'echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | sudo tee /etc/apt/sources.list.d/zulu.list' && \
    apt-get update && \
    apt-get install -y zulu17-jdk && \
    apt-get clean all

RUN sh -c 'curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg' && \
    sh -c 'echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list' && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean all

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable" && \
    apt-get install -y docker-ce docker-ce-cli containerd.io && \
    apt-get clean all

RUN apt-add-repository "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_22.04 /"  && \
    sh -c 'curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_22.04/Release.key | sudo apt-key add -' && \
    apt-get update && \
    apt-get -y install podman && \
    apt-get clean all

RUN rm -rf /var/lib/shared/overlay-images && \
    rm -rf /var/lib/shared/overlay-layers && \
    rm -rf /var/lib/shared/overlay-images/images.lock /var/lib/shared/overlay-layers/layers.lock && \
    rm -f /etc/containers/storage.conf

RUN apt-get update && \
    apt-get upgrade -y

RUN docker --version && podman --version

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

ADD entrypoint.sh /entrypoint.sh
ADD daemon.json /etc/docker/daemon.json
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint.sh"]
