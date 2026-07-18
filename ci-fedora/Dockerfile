FROM registry.fedoraproject.org/fedora:rawhide

RUN echo "install_weak_deps=False" >> /etc/dnf/dnf.conf && \
    echo "minrate=10M" >> /etc/dnf/dnf.conf && \
    export FORCE_COLUMNS=200 && \
    rpm -q dnf5 || (time dnf -y install dnf5 ; time dnf clean all ) && \
    time dnf5 -y install dnf5-plugins cmake git-core wget python3-pytest python3-pytest-xdist && \
    wget https://github.com/boutproject/BOUT-dev/raw/refs/heads/next/requirements.txt && \
    time dnf5 -y install $(for f in $(grep -o '^[^=><]*' requirements.txt  | tr '[:upper:]' '[:lower:]' ) ;  do echo "python3dist($f)"  ; done) && \
    rm requirements.txt && \
    time dnf5 copr enable -y davidsch/fixes4bout && \
    time dnf5 -y upgrade && \
    time dnf5 -y builddep bout++ && \
    time dnf5 -y install cpptrace-devel && \
    time dnf5 clean all

RUN useradd test -G wheel -p '$6$MoHfQDiMU5ajgDMm$9FAMLxMflKwQCZ.sJBNG6wLGnPeySVizdA8wN0k8LSXKPkCfOb/sM9Y4jKFvh5rzKSwLtYSTzvJyETqrFlxBV.' \
    && echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# user: boutuser
# password: boutforever
USER test
WORKDIR /home/test

RUN git clone https://github.com/boutproject/BOUT-dev --depth 1 && \
    cd BOUT-dev && \
    git checkout next && \
    sed -i .ci_fedora.sh -e '/cp -a \/tmp/d' && \
    sh .ci_fedora.sh openmpi && \
    git clean -xfd && \
    sed -i tests/integrated/CMakeLists.txt -e /communications/d && \
    sh .ci_fedora.sh mpich && \
    git checkout -- tests && \
    cd .. && rm -rf BOUT-dev
