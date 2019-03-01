FROM rootproject/root-ubuntu16:6.12

# Run the following commands as super user (root):
USER root
WORKDIR /root

SHELL [ "/bin/bash", "-c" ]

# Install required packages for notebooks
RUN apt-get update && \
    apt-get upgrade -qq -y && \
    apt-get install -qq -y \
        python-pip \
        wget \
        git \
        cmake && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Use sudo -H pip instead of pip install --user as jupyter will be called later by USER jovyan
RUN sudo -H pip install --upgrade --no-cache-dir pip setuptools wheel && \
    sudo -H pip install --no-cache-dir \
       jupyter \
       metakernel \
       zmq

# Install XRootD
ADD binder/install_xrootd.sh install_xrootd.sh
RUN bash install_xrootd.sh && \
    rm install_xrootd.sh
ENV PATH /opt/xrootd/bin:${PATH}
ENV LD_LIBRARY_PATH /opt/xrootd/lib

ENV DISPLAY localhost:0.0.0.0
# c.f. https://mybinder.readthedocs.io/en/latest/tutorials/dockerfile.html#preparing-your-dockerfile
ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}
WORKDIR /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Have Jupyter notebooks launch without command line options
RUN jupyter notebook --generate-config && \
    sed -i -e "/allow_root/ a c.NotebookApp.allow_root = True" ~/.jupyter/jupyter_notebook_config.py && \
    sed -i -e "/custom_display_url/ a c.NotebookApp.custom_display_url = \'http://localhost:8888\'" ~/.jupyter/jupyter_notebook_config.py && \
    sed -i -e "/c.NotebookApp.ip/ a c.NotebookApp.ip = '0.0.0.0'" ~/.jupyter/jupyter_notebook_config.py && \
    sed -i -e "/open_browser/ a c.NotebookApp.open_browser = False" ~/.jupyter/jupyter_notebook_config.py
# Prepare the JupyROOT kernel
RUN cp ~/.jupyter/jupyter_notebook_config.py ${HOME} && \
    mkdir -p ${HOME}/.local/share/jupyter/kernels && \
    cp -r /usr/local/etc/root/notebook/kernels/root ~/.local/share/jupyter/kernels

# Make sure the contents of the repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

# Specify the default command to run
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
