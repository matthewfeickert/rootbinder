FROM rootproject/root-ubuntu16:6.12

# Run the following commands as super user (root):
USER root

SHELL [ "/bin/bash", "-c" ]

# Install required packages for notebooks
RUN apt-get update && \
    apt-get upgrade -qq -y && \
    apt-get install -qq -y \
        python-pip \
        wget \
        git
RUN sudo -H pip install --upgrade pip setuptools wheel && \
    sudo -H pip install \
       jupyter \
       metakernel \
       zmq && \
    rm -rf /var/lib/apt/lists/*

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
