FROM rootproject/root-ubuntu16:b16855622aac

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

# c.f. https://mybinder.readthedocs.io/en/latest/tutorials/dockerfile.html#preparing-your-dockerfile
ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Make sure the contents of the repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

# Specify the default command to run
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
