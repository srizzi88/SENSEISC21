FROM ubuntu:18.04

SHELL ["/bin/bash", "-c"]

# directory structure for the build
ENV BASEDIR=/sensei
ENV SRCDIR=$BASEDIR/src
ENV INSTALLDIR=$BASEDIR/install
ENV BUILDDIR=$BASEDIR/build

RUN mkdir $BASEDIR
RUN mkdir $SRCDIR
RUN mkdir $INSTALLDIR
RUN mkdir $BUILDDIR

# ubuntu packages
RUN apt-get update 
RUN apt-get install -y \
    git \
    build-essential \
    libmpich-dev \
    wget

# install cmake binary from Kitware
WORKDIR ${INSTALLDIR}
RUN wget https://github.com/Kitware/CMake/releases/download/v3.21.3/cmake-3.21.3-linux-x86_64.tar.gz && \
    tar xvzf cmake-3.21.3-linux-x86_64.tar.gz && \
    mv cmake-3.21.3-linux-x86_64 cmake && \
    rm cmake-3.21.3-linux-x86_64.tar.gz
ENV PATH=${INSTALLDIR}/cmake/bin:$PATH

##########################################
###              LAMMPS                ###
##########################################

# clone LAMMPS
WORKDIR ${SRCDIR}
RUN git clone https://github.com/lammps/lammps && \
    cd lammps && \
    git checkout release

# build lammps
WORKDIR ${SRCDIR}/lammps/src
RUN make mpi mode=lib -j8

##########################################
###             VTK 8.2                ###
##########################################

# clone VTK
WORKDIR ${SRCDIR}
RUN git clone https://gitlab.kitware.com/vtk/vtk.git && \
    cd vtk && \
    git checkout v8.2.0

# config VTK
WORKDIR ${BASEDIR}
RUN cmake -S ${SRCDIR}/vtk -B ${BUILDDIR}/vtk \
 -DVTK_Group_Imaging=OFF \
 -DVTK_Group_MPI=OFF \
 -DVTK_Group_Qt=OFF \
 -DVTK_Group_Rendering=OFF \
 -DVTK_Group_StandAlone=ON \
 -DVTK_Group_Tk=OFF \
 -DVTK_Group_Views=OFF \
 -DVTK_Group_Web=OFF \
 -DVTK_RENDERING_BACKEND=None \
 -DCMAKE_BUILD_TYPE=Debug \
 -DBUILD_TESTING=OFF \
 -DCMAKE_INSTALL_PREFIX=${INSTALLDIR}/vtk

# build VTK
WORKDIR ${BUILDDIR}/vtk
RUN make -j8

# install VTK
WORKDIR ${BUILDDIR}/vtk
RUN make -j8 install

##########################################
###            ADIOS 2.7.1             ###
##########################################

# python needed
RUN apt-get install -y python3-dev 

# clone ADIOS2
WORKDIR ${SRCDIR}
RUN git clone https://github.com/ornladios/ADIOS2.git && \
    cd ADIOS2 && \
    git checkout v2.7.1

# config ADIOS2
WORKDIR ${BASEDIR}
RUN cmake -S ${SRCDIR}/ADIOS2 -B ${BUILDDIR}/adios \
 -DCMAKE_INSTALL_PREFIX=${INSTALLDIR}/adios \
 -DADIOS2_USE_Fortran=OFF \
 -DADIOS2_BUILD_EXAMPLES=OFF \
 -DCMAKE_BUILD_TYPE=Release 

# build ADIOS2
WORKDIR ${BUILDDIR}/adios
RUN make -j8

# install ADIOS2
WORKDIR ${BUILDDIR}/adios
RUN make -j8 install

##########################################
###            SENSEI Devel            ###
##########################################

# clone SENSEI
WORKDIR ${SRCDIR}
# clone my fork with LAMMPS
RUN git clone https://github.com/srizzi88/SENSEI.git && \
    cd SENSEI && \
    git checkout lammps

# config SENSEI
WORKDIR ${BASEDIR}
ENV LAMMPS_DIR=${BASEDIR}/src/lammps
ENV VTK_DIR=${INSTALLDIR}/vtk/lib/cmake/vtk-8.2
ENV ADIOS2_DIR=${INSTALLDIR}/adios/lib/cmake/adios2

RUN cmake -S ${SRCDIR}/SENSEI -B ${BUILDDIR}/sensei \
  -DCMAKE_INSTALL_PREFIX=$INSTALLDIR/sensei \
  -DVTK_DIR=$VTK_DIR \
  -DENABLE_VTK_IO=ON \
  -DLAMMPS_DIR=$LAMMPS_DIR \
  -DENABLE_LAMMPS=ON \
  -DENABLE_MANDELBROT=OFF \
  -DENABLE_OSCILLATORS=OFF \
  -DENABLE_ADIOS2=ON \
  -DADIOS2_DIR=$ADIOS2_DIR 

# build SENSEI
WORKDIR ${BUILDDIR}/sensei
RUN make -j8

# install SENSEI
WORKDIR ${BUILDDIR}/sensei
RUN make -j8 install

############################
####    Final settings   ###
############################

WORKDIR ${INSTALLDIR}/sensei/bin
ENV LD_LIBRARY_PATH=${INSTALLDIR}/vtk/lib:${INSTALLDIR}/adios/lib:$LD_LIBRARY_PATH

# remove source and build directories to streamline container
RUN rm -rf ${SRCDIR} ${BUILDDIR}

# add input files for simulation and SENSEI xml config
COPY INPUTFILES ./INPUTFILES
