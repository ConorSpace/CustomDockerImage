FROM osrf/ros:humble-desktop-full

RUN apt-get update \
    && apt-get install -y nano \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
    bash-completion \
    git \
    nano \
    python3.10=3.10.12-* \
    python3-argcomplete \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y x11-apps libx11-xcb1 && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get upgrade -y

COPY  . /app/

ARG USERNAME=areo
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# ARG REPO_VERSION_PX4=v1.1.0
# ARG REPO_VERSION_DDS=v2.4.1

#Creating a non-root user
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && mkdir /home/$USERNAME/.config && chown $USER_UID:$USER_GID /home/$USERNAME/.config


#setting up sudo
RUN apt-get update \ 
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \ 
    && rm -rf /var/lib/apt/lists/*

# PX4 Autopilot
# RUN apt-get update \
#     && git clone https://github.com/PX4/PX4-Autopilot.git --recursive \
#     && bash ./PX4-Autopilot/Tools/setup/ubuntu.sh \
#     # && sudo chown -R areo:areo /PX4-Autopilot/ \
#     # && git config --global --add safe.directory /PX4-Autopilot \
#     && cd PX4-Autopilot/ \
#     # && git checkout tags/$REPO_VERSION_PX4 \
#     && make px4_sitl \
#     && rm -rf /var/lib/apt/lists/*

# # Micro XRCE DDS 
# RUN apt-get update \
#     && git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git \
#     # && sudo chown -R areo:areo /Micro-XRCE-DDS-Agent/ \
#     && cd Micro-XRCE-DDS-Agent \
#     # && git checkout tags/$REPO_VERSION_DDS \
#     && mkdir build \
#     && cd build \
#     && cmake .. \
#     && make \
#     && sudo make install \
#     && sudo ldconfig /usr/local/lib/ \
#     && rm -rf /var/lib/apt/lists/*


COPY entrypoint.sh /entrypoint.sh
COPY bashrc /home/${USERNAME}/.bashrc


ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]

CMD [ "bash" ]


#docker run -it --user areo --network=host --ipc=host -v /tmp/.X11-unix-copy:/tmp/.X11-unix:rw --env=DISPLAY --gpus all --env="QT_X11_NO_MITSHM=1" --env="NVIDIA_DRIVER_CAPABILITIES=all" --env="NVIDIA_VISIBLE_DEVICES=all" --device=/dev/dri:/dev/dri --privileged --security-opt apparmor:unconfined my_image