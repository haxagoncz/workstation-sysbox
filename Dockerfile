FROM nestybox/ubuntu-bionic-systemd

RUN apt-get update
RUN apt-get install -y wget openssh-server

RUN wget https://github.com/tsl0922/ttyd/releases/download/1.7.2/ttyd.x86_64

RUN mv ttyd.x86_64 /usr/bin/ttyd
RUN chmod +x /usr/bin/ttyd

COPY ttyd.service /etc/systemd/system/ttyd.service

RUN chmod 644 /etc/systemd/system/ttyd.service

RUN systemctl enable ttyd
RUN systemctl enable ssh
