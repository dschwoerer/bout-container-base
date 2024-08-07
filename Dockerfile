FROM registry.fedoraproject.org/fedora:latest

ARG MPI=mpich
ARG TYPE=minimal
ARG PETSC_VERSION=3.21.4
ARG OPENMP=1

RUN test ".$TYPE" != ".mini" || echo "install_weak_deps=False" >> /etc/dnf/dnf.conf

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Some convinient tools
RUN test ".$TYPE" = ".mini" || dnf -y install dnf-plugins-core python3-pip emacs vim nano sudo diffutils git && dnf clean all

# BOUT++ deps
RUN dnf -y install netcdf-devel netcdf-cxx4-devel hdf5-devel fftw-devel cmake python3-numpy python3-Cython python3-netcdf4 python3-scipy python3-boututils python3-boutdata flexiblas-devel gcc-c++ mpark-variant-devel python3-jinja2 petsc-$MPI-devel hdf5-$MPI-devel sundials-$MPI-devel sundials-devel git-core bison flex diffutils fakeroot && dnf clean all

RUN useradd boutuser -G wheel -p '$6$MoHfQDiMU5ajgDMm$9FAMLxMflKwQCZ.sJBNG6wLGnPeySVizdA8wN0k8LSXKPkCfOb/sM9Y4jKFvh5rzKSwLtYSTzvJyETqrFlxBV.'

RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# user: boutuser
# password: boutforever
USER boutuser
WORKDIR /home/boutuser


ENV MPI_BIN=/usr/lib64/$MPI/bin \
    MPI_SYSCONFIG=/etc/$MPI-x86_64 \
    MPI_FORTRAN_MOD_DIR=/usr/lib64/gfortran/modules/$MPI \
    MPI_INCLUDE=/usr/include/$MPI-x86_64 \
    MPI_LIB=/usr/lib64/$MPI/lib \
    MPI_MAN=/usr/share/man/$MPI-x86_64 \
    MPI_PYTHON_SITEARCH=/usr/lib64/python3.11/site-packages/$MPI \
    MPI_PYTHON3_SITEARCH=/usr/lib64/python3.11/site-packages/$MPI \
    MPI_COMPILER=$MPI-x86_64 \
    MPI_SUFFIX=_$MPI \
    MPI_HOME=/usr/lib64/$MPI


ENV PATH=$MPI_BIN:$PATH \
    LD_LIBRARY_PATH=$MPI_LIB:$LD_LIBRARY_PATH \
    PKG_CONFIG_PATH=$MPI_LIB/pkgconfig:$PKG_CONFIG_PATH \
    MANPATH=$MPI_MAN:$MANPATH


# PETSc
RUN VER=$PETSC_VERSION && curl https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-$VER.tar.gz > petsc-$VER.tar.gz \
 && tar -xf petsc-$VER.tar.gz \
 && sudo mkdir -p  /opt/petsc && sudo chown boutuser /opt/petsc \
 && cd petsc-$VER/ \
 && /usr/bin/python3 ./configure --with-mpi=yes --with-shared-libraries --with-precision=double --with-scalar-type=real \
    --download-mumps=1 --download-scalapack=1 --download-blacs=1 --download-fblas-lapack=1 --download-hypre=1 \
    --download-parmetis=1 --download-ptscotch=1 --download-metis=1 --with-openmp=$OPENMP --with-debugging=0 --prefix=/opt/petsc \
    --with-python-exec=/usr/bin/python3 --with-mpi-dir=/usr/lib64/$MPI --with-blas-lib=flexiblas --with-lapack-lib=flexiblas || (cat configure.log ; exit 1) \
 && make all \
 && make install \
 && find /opt -name *.a -delete \
 && (test ".$TYPE" != ".mini" || rm -rf /opt/petsc/share/petsc/examples ) \
 && sudo chown root -R /opt/petsc \
 && cd .. && rm -rf .* * \

# check gets stuck with openmpi
# && make check \
# test is really slow
# && make test \
