FROM registry.fedoraproject.org/fedora:latest

ARG MPI=mpich
ARG TYPE=minimal
ARG PETSC_VERSION=3.16.4
ARG OPENMP=1

RUN test ".$TYPE" != ".mini" || echo "install_weak_deps=False" >> /etc/dnf/dnf.conf && rm /etc/yum.repos.d/*modular*

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Some convinient tools
RUN test ".$TYPE" = ".mini" || dnf -y install dnf-plugins-core python3-pip emacs vim nano sudo diffutils git && dnf clean all

# BOUT++ deps
RUN dnf -y install netcdf-devel netcdf-cxx4-devel hdf5-devel fftw-devel cmake python3-numpy python3-Cython python3-netcdf4 python3-scipy python3-boututils python3-boutdata flexiblas-devel gcc-c++ mpark-variant-devel python3-jinja2 petsc-$MPI-devel hdf5-$MPI-devel sundials-$MPI-devel sundials-devel git-core bison flex diffutils fakeroot && dnf clean all


# PETSc
RUN VER=$PETSC_VERSION && curl https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-$VER.tar.gz > petsc-lite-$VER.tar.gz \
 && tar -xf petsc-lite-$VER.tar.gz \
 && cd petsc-$VER/ \
 && /usr/bin/python3 ./configure --with-clanguage=cxx --with-mpi=yes --with-shared-libraries --with-precision=double --with-scalar-type=real \
    --download-mumps=1 --download-scalapack=1 --download-blacs=1 --download-fblas-lapack=1 \
    --download-parmetis=1 --download-ptscotch=1 --download-metis=1 --with-openmp=$OPENMP --with-debugging=0 --prefix=/opt/petsc \
    --with-python-exec=/usr/bin/python3 --with-mpi-dir=/usr/lib64/$MPI --with-blas-lib=flexiblas --with-lapack-lib=flexiblas\
 && make all \
 && make install \
 && make check \
 && rm -r /petsc-$VER/ \
 && find /opt -name *.a -delete \
 && (test ".$TYPE" != ".mini" || rm -rf /opt/petsc/share/petsc/examples )
# test is really slow
# && make test \


