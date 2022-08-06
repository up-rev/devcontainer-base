FROM ubuntu:18.04 as dev


ENV DEBIAN_FRONTEND noninteractive


#passwords as arguments so they can be changed
ARG DEV_PW=password
ARG JENKINS_PW=jenkins

RUN apt-get update && apt-get install -y --fix-missing --no-install-recommends \ 
    wget \ 
    cmake \
    build-essential \
    openssl \
    make \ 
    git \
    python3 \
    python3-pip \
    python3-setuptools \
    plantuml \
    graphviz \
    texlive \
    latexmk \
    texlive-science \
    texlive-formats-extra \ 
    tex-gyre && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* 

#Copy the latest release of plantuml. Ubuntu 18.04 package manager has an older one without timing diagram support
RUN wget https://github.com/plantuml/plantuml/releases/download/v1.2022.1/plantuml-1.2022.1.jar -O /usr/share/plantuml/plantuml.jar

RUN python3 -m pip install -U --force-reinstall pip


#sphinx dependencies 
RUN pip3 install wheel sphinx sphinxcontrib-plantuml sphinx-rtd-theme recommonmark restview docxbuilder docxbuilder[math]


#mrtutils 
RUN pip3 install mrtutils


# Add user dev to the image
RUN adduser --quiet dev && \
    echo "dev:$DEV_PW" | chpasswd && \
    chown -R dev /home/dev 

######################################################################################################
#                           Stage: jenkins                                                           #
######################################################################################################

# FROM dev as jenkins

# ARG JENKINS_PW=jenkins  
# RUN apt-get update && apt-get install -y --no-install-recommends \ 
#     openssh-server \
#     openjdk-8-jdk  \
#     openssh-server \
#     ca-certificates 

# RUN apt-get clean all && rm -rf /var/lib/apt/lists/*

# RUN adduser --quiet jenkins && \
#     echo "jenkins:$JENKINS_PW" | chpasswd && \
#     mkdir /home/jenkins/.m2 && \
#     mkdir /home/jenkins/jenkins && \
#     chown -R jenkins /home/jenkins 


# # Setup SSH server
# RUN mkdir /var/run/sshd
# RUN echo 'root:password' | chpasswd
# RUN sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# # SSH login fix. Otherwise user is kicked off after login
# RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# ENV NOTVISIBLE="in users profile"
# RUN echo "export VISIBLE=now" >> /etc/profile

# ENV PATH="/opt/stm32cubeide:${PATH}"

# EXPOSE 22
# CMD ["/usr/sbin/sshd", "-D"]