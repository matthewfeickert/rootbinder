# No tags other than `latest`, so use the SHA
# c.f. https://hub.docker.com/r/rootproject/root-cc7
FROM rootproject/root-cc7@sha256:861c9f9ce7adba0daaa0be1a6b2630d0efb652e35843e06d0c121cbf721b23be

# Run the following commands as super user (root):
USER root

SHELL [ "/bin/bash", "-c" ]

# Install libraries and (missing) xRootD libraries
RUN yum upgrade -y -q && \
    yum install -y \
        python-pip \
        wget \
        git && \
    yum install -y \
        xrootd-client \
        python2-xrootd && \
    yum clean all && \
    rm -rf /var/lib/yum/history/*

# Install required packages for notebooks
RUN pip install --upgrade --no-cache-dir pip setuptools wheel && \
    pip install --no-cache-dir \
       jupyter \
       metakernel \
       zmq

ENV DISPLAY localhost:0.0.0.0
# c.f. https://mybinder.readthedocs.io/en/latest/tutorials/dockerfile.html#preparing-your-dockerfile
ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}
WORKDIR /home/${NB_USER}

# adduser on CentOS doesn't have --disabled-password and --gecos
RUN adduser \
    --comment "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Have Jupyter notebooks launch without command line options
# and prepare the JupyROOT kernel
RUN jupyter notebook --generate-config && \
    sed -i -e "/allow_root/ a c.NotebookApp.allow_root = True" ${HOME}/.jupyter/jupyter_notebook_config.py && \
    sed -i -e "/custom_display_url/ a c.NotebookApp.custom_display_url = \'http://localhost:8888\'" ${HOME}/.jupyter/jupyter_notebook_config.py && \
    sed -i -e "/c.NotebookApp.ip/ a c.NotebookApp.ip = '0.0.0.0'" ${HOME}/.jupyter/jupyter_notebook_config.py && \
    sed -i -e "/open_browser/ a c.NotebookApp.open_browser = False" ${HOME}/.jupyter/jupyter_notebook_config.py && \
    cp ${HOME}/.jupyter/jupyter_notebook_config.py ${HOME} && \
    mkdir -p ${HOME}/.local/share/jupyter/kernels && \
    cp -r /usr/local/etc/root/notebook/kernels/root ${HOME}/.local/share/jupyter/kernels

# Make sure the contents of the repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

# Specify the default command to run
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
