FROM ubuntu:19.04

RUN apt update && \
    apt upgrade -y && \
    apt install -y software-properties-common sudo curl dumb-init && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9 && \
    apt-add-repository 'deb http://repos.azulsystems.com/ubuntu stable main' && \
    add-apt-repository -y ppa:projectatomic/ppa && \
    apt clean all

RUN apt update && \
    apt install -y zulu-11 && \
    apt clean all

RUN apt update && \
    apt install -y podman fuse-overlayfs iptables-nftables-compat nftables && \
    curl https://raw.githubusercontent.com/projectatomic/registries/master/registries.fedora -o /etc/containers/registries.conf && \
    curl https://raw.githubusercontent.com/containers/skopeo/master/default-policy.json -o /etc/containers/policy.json && \
    apt clean all

RUN rm -rf /var/lib/shared/overlay-images && \
    rm -rf /var/lib/shared/overlay-layers && \
    rm -rf /var/lib/shared/overlay-images/images.lock /var/lib/shared/overlay-layers/layers.lock && \
    rm -f /etc/containers/storage.conf

RUN mkdir /home/jenkins
ENV HOME /home/jenkins
RUN chown -R 1001:0 $HOME && \
    chmod -R g+rw $HOME && \
    useradd -u 1001 jenkins && \
    usermod -aG sudo jenkins && \
#    usermod -aG docker jenkins && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable" && \
    apt-get install docker-ce docker-ce-cli containerd.io && \
    rm /usr/sbin/iptables && \
    ln -s /usr/sbin/iptables-compat /usr/sbin/iptables

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint.sh"]
