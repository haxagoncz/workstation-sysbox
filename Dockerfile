FROM nestybox/ubuntu-bionic-systemd

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y wget openssh-server iputils-ping tcpdump ldnsutils nano

RUN wget -O install-snoopy.sh https://github.com/a2o/snoopy/raw/install/install/install-snoopy.sh && chmod 755 install-snoopy.sh && ./install-snoopy.sh stable

RUN rm -f ./install-snoopy.sh

RUN echo "output = file:/var/log/snoopy.log" >> /etc/snoopy.ini
RUN touch /var/log/snoopy.log && chmod 666 /var/log/snoopy.log

RUN wget https://github.com/tsl0922/ttyd/releases/download/1.7.2/ttyd.x86_64

RUN mv ttyd.x86_64 /usr/bin/ttyd
RUN chmod +x /usr/bin/ttyd

COPY ttyd.service /etc/systemd/system/ttyd.service

RUN chmod 644 /etc/systemd/system/ttyd.service

RUN systemctl enable ttyd
RUN systemctl enable ssh
