# 使用 Ubuntu 20.04 基础镜像
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# 安装 apt-utils 避免 debconf 警告
RUN apt-get update && apt-get install -y apt-utils

# 设置上海时区
RUN apt-get update && apt-get install -y tzdata \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

# 安装依赖 + locales
RUN apt-get update && apt-get install -y \
    build-essential \
    nasm \
    wget \
    make \
    g++ \
    binutils \
    curl \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    git \
    sudo \
    vim \
    software-properties-common \
    locales \
    zsh

# locale
RUN locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# Ubuntu 14.04 源
RUN echo "deb http://dk.archive.ubuntu.com/ubuntu/ trusty main universe" >> /etc/apt/sources.list && \
    echo "deb http://dk.archive.ubuntu.com/ubuntu/ trusty-updates main universe" >> /etc/apt/sources.list && \
    apt-get update

# gcc 4.4
RUN apt-get install -y gcc-4.4 g++-4.4 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.4 40

# # 创建普通用户 xuzichun，默认 shell = zsh
# RUN useradd -m -s /usr/bin/zsh xuzichun && \
#     echo "xuzichun ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# 创建普通用户 xuzichun，并指定 UID/GID 与宿主机一致
ARG HOST_UID=1000
ARG HOST_GID=1000
RUN groupadd -g $HOST_GID xuzichun \
    && useradd -m -u $HOST_UID -g $HOST_GID -s /usr/bin/zsh xuzichun \
    && echo "xuzichun ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers



# 拷贝 oh-my-zsh 和 zshrc (你在 build 前要先 cp 到 build context)
COPY --chown=xuzichun:xuzichun .oh-my-zsh /home/xuzichun/.oh-my-zsh
COPY --chown=xuzichun:xuzichun .zshrc /home/xuzichun/.zshrc

# 下载 gitstatusd for powerlevel10k
RUN mkdir -p /home/xuzichun/.cache/gitstatus && \
    cd /home/xuzichun/.cache/gitstatus && \
     wget https://gitee.com/romkatv/gitstatus/raw/release-v1.5.4/release/gitstatusd-linux-x86_64.tar.gz && \
    tar -xzf gitstatusd-linux-x86_64.tar.gz && \
    rm gitstatusd-linux-x86_64.tar.gz && \
    chown -R xuzichun:xuzichun /home/xuzichun/.cache

    
# 默认非 root
USER xuzichun

# 设工作目录
WORKDIR /home/xuzichun/boch/

# 默认执行 zsh
CMD [ "zsh" ]

