FROM registry.fedoraproject.org/fedora:rawhide

RUN echo "install_weak_deps=False" >> /etc/dnf/dnf.conf && \
    echo "minrate=10M" >> /etc/dnf/dnf.conf && \
    export FORCE_COLUMNS=200 && \
    rpm -q dnf5 || (time dnf -y install dnf5 ; time dnf clean all ) ; \
    time dnf5 -y install dnf5-plugins cmake python3-zoidberg python3-natsort python3-boututils && \
    time dnf5 copr enable -y davidsch/fixes4bout ; \
    time dnf5 -y upgrade && \
    time dnf5 -y builddep bout++ && \
    time dnf5 clean all && \
    useradd test

RUN useradd test -G wheel -p '$6$MoHfQDiMU5ajgDMm$9FAMLxMflKwQCZ.sJBNG6wLGnPeySVizdA8wN0k8LSXKPkCfOb/sM9Y4jKFvh5rzKSwLtYSTzvJyETqrFlxBV.'

RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# user: boutuser
# password: boutforever
USER test
WORKDIR /home/test
