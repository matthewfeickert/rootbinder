FROM rootproject/root-ubuntu16

MAINTAINER Enric Tejedor Saavedra <enric.tejedor.saavedra@cern.ch>

USER root

# Install ROOT prerequisites
RUN apt-get -qq -y update && \
    apt-get -qq -y upgrade && \
    apt-get -qq -y install \
    libx11-6 \
    libxext6 \
    libxft2 \
    libxpm4 \
    wget

# Install ROOT additional libraries
RUN apt-get install -y \
    r-base \
    r-base-dev

# Install Python 3.6
RUN wget https://www.python.org/ftp/python/3.6.6/Python-3.6.6.tgz && \
    tar -xvzf Python-3.6.6.tgz > /dev/null && \
    rm Python-3.6.6.tgz && \
    cd Python-3.6.6 && \
    ./configure --with-bz2 && \
    make && \
    make install
RUN echo "alias python=python3" >> ~/.bashrc
RUN pip3 install --upgrade --quiet pip setuptools wheel

# Install R packages
RUN R -e "install.packages(c('Rcpp','RInside'), repos='http://cran.us.r-project.org')"

# Download and install Fastjet
RUN wget http://root.cern.ch/notebooks/rootbinderdata/fastjet.tar.gz && \
    tar xzf fastjet.tar.gz && \
    rm fastjet.tar.gz

# Set ROOT environment
ENV ROOTSYS         "/opt/root"
ENV PATH            "$ROOTSYS/bin:$ROOTSYS/bin/bin:$PATH"
ENV LD_LIBRARY_PATH "$ROOTSYS/lib:$LD_LIBRARY_PATH"
ENV PYTHONPATH      "$ROOTSYS/lib:PYTHONPATH"

# Set ROOT environment for Fastjet
ENV LD_LIBRARY_PATH "/opt/fastjet/lib:$LD_LIBRARY_PATH"
ENV ROOT_INCLUDE_PATH "/opt/fastjet/include"

# Customise the ROOTbook
RUN pip3 install --upgrade pip
RUN pip3 install metakernel
RUN mkdir -p                                 $HOME/.ipython/kernels
RUN cp -r $ROOTSYS/etc/notebook/kernels/root $HOME/.ipython/kernels
RUN mkdir -p                                 $HOME/.ipython/profile_default/static
RUN cp -r $ROOTSYS/etc/notebook/custom       $HOME/.ipython/profile_default/static
