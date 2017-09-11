FROM ubuntu:xenial

RUN apt-get update -y && apt-get install -y \
    ntp \
    nano \
    rsync \
    openssh-server \
    gnupg2 \
    curl

RUN mkdir -p /homework/klavoie/hw

COPY p54-lango.pdf /homework/klavoie/hw
COPY p45-sproull.pdf /homework/klavoie/hw

RUN curl -O https://raw.githubusercontent.com/lavoieunh/week2gpg/master/gpgfile.txt

RUN gpg2 --batch --gen-key gpgfile.txt

WORKDIR /homework/klavoie/hw

RUN sha256sum * > shasum.txt

RUN mkdir -p /homework/klavoie/backup

RUN rsync -azvv /homework/klavoie/hw /homework/klavoie/backup

RUN mkdir /var/run/sshd

RUN echo 'root:homework' | chpasswd

RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
