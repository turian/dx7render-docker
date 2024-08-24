#FROM ubuntu:18.04
FROM ubuntu:20.04
#FROM ubuntu:16.04
ENV LANG C.UTF-8
LABEL maintainer="lastname@gmail.com"
LABEL version="0.1"
LABEL description="learnfm's DX7 synthesizer, dockerized"

WORKDIR /root/

ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y lsb-release software-properties-common
#RUN add-apt-repository universe
RUN apt-get update
#RUN apt-get upgrade -y

# Build tools
#RUN apt-get install -y git build-essential python-pip
RUN apt-get install -y git build-essential python2
#RUN apt-get install -y git build-essential python2-pip
#RUN apt-get install -y git build-essential
#RUN apt-get install -y clang
#RUN apt-get install -y clang-9
#RUN apt-get install -y vim rsync

RUN apt-get install -y wget
#RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
# Add LLVM repository and install clang-12
RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 12 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-12 100 --slave /usr/bin/clang++ clang++ /usr/bin/clang++-12


#RUN apt-get remove cmake -y
#RUN apt-get install -y apt-transport-https ca-certificates gnupg software-properties-common wget  libssl1.0-dev 
#RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -
#RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' > /dev/null
#RUN apt-get update
#RUN apt-get install cmake -y

# Some command line utils you probably want
#RUN apt-get install -y sudo less bc screen tmux unzip vim wget

#RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/c++ 40
#RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-9 100 --slave /usr/bin/clang++ clang++ /usr/bin/clang++-9
#RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-9 60
#RUN update-alternatives --config c++

RUN apt-get install -y vim curl
#RUN apt-get install -y clang

# Add non root user
RUN useradd -ms /bin/bash dx7 && echo "dx7:dx7" | chpasswd && adduser dx7 sudo
USER dx7
ENV HOME /home/dx7

USER root
RUN apt-get install -y python2-dev
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
#RUN curl https://bootstrap.pypa.io/get-pip.py --output get-pip.py
RUN python2 get-pip.py && rm get-pip.py


USER dx7
# Clone learnfm from master, and build
RUN cd ~ && git clone https://github.com/turian/learnfm.git
RUN cd ~/learnfm/ && git checkout unix-fixes
RUN cd ~/learnfm/dx7core/ && perl -i -pe 's/g\+\+/clang++-12/;' Makefile
RUN cd ~/learnfm/dx7core/ && perl -i -pe 's/g\+\+/clang++-12/;' setup.py
RUN cd ~/learnfm/dx7core/ && perl -i -pe 's/gcc/clang-12/;' setup.py
RUN cd ~/learnfm/dx7core/ && make
RUN cd ~/learnfm/dx7core/ && perl -i -pe 's/\/Users\/bwhitman\/outside/\/home\/dx7/' pydx7.cc
RUN cd ~/learnfm/dx7core/ && python2 setup.py build

USER root
RUN cd ~/learnfm/dx7core/ && python2 setup.py install
RUN apt-get install -y wget
RUN apt-get install -y unzip
#RUN pip install --upgrade pip
RUN apt-get install -y libasound2-dev
#RUN pip install --upgrade tqdm ipython numpy soundfile python-slugify mido python-rtmidi
#RUN python2 -m pip install --upgrade tqdm ipython numpy soundfile python-slugify mido python-rtmidi
#RUN python2 -m pip install --upgrade tqdm ipython numpy soundfile python-slugify mido
RUN python2 -m pip install --upgrade tqdm ipython numpy soundfile mido
RUN python2 -m pip install python-slugify==1.2.6
RUN python2 -m pip install --upgrade python-rtmidi==1.4.7

RUN apt-get install -y sudo vim

## --no-cache-dir 
## numpy==1.16
##RUN pip install --upgrade tqdm ipython numpy soundfile python-slugify mido python-rtmidi
RUN apt-get install -y libsndfile-dev vorbis-tools
#
#USER dx7
#
##RUN cd ~/dx7/ && LD_LIBRARY_PATH="/usr/lib/python3.6/config-3.6m-x86_64-linux-gnu/:$LD_LIBRARY_PATH" /usr/bin/cmake --build buildpy --config Release --target dx7py
##
##USER dx7
##COPY example.py /home/dx7/example.py
##COPY run.py /home/dx7/run.py
##
##RUN cd ~/dx7/ && ./build-linux.sh build --local --project=headless
##RUN mkdir -p /home/dx7/.local/share/dx7
##RUN cd ~/dx7/ && ./build-linux.sh install --local --project=headless
##RUN mv ~/dx7/buildpy/dx7py.cpython-36m-x86_64-linux-gnu.so ~
##RUN rm -Rf ~/dx7
##RUN echo "PYTHONPATH=\"$PYTHONPATH:/home/dx7\"" >> ~/.bashrc
##
##USER root
### Some of these packages are not totally necessary, but useful nonetheless
##RUN pip3 install --upgrade tqdm ipython numpy soundfile python-slugify
### remove unused files
##RUN apt-get remove -y libcairo-dev libxkbcommon-x11-dev libxkbcommon-dev libxcb-cursor-dev libxcb-keysyms1-dev libxcb-util-dev
##RUN apt-get remove -y git build-essential cmake gcc
##RUN apt-get autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
##
USER dx7
