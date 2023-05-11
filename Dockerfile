FROM rust as rustbuild

RUN apt-get update
RUN apt-get install -y libpam0g-dev
RUN git clone https://github.com/coastalwhite/lemurs.git /lemurs
RUN cd /lemurs && cargo build --release

#FROM nestybox/ubuntu-focal-systemd
FROM ubuntu:jammy

#
# Systemd installation
#
RUN apt-get update &&                            \
    apt-get install -y --no-install-recommends   \
            systemd                              \
            systemd-sysv                         \
            libsystemd0                          \
            ca-certificates                      \
            dbus                                 \
            iptables                             \
            iproute2                             \
            kmod                                 \
            locales                              \
            sudo                                 \
            udev &&                              \
                                                 \
    # Prevents journald from reading kernel messages from /dev/kmsg
    echo "ReadKMsg=no" >> /etc/systemd/journald.conf &&               \
                                                                      \
    # Housekeeping
    apt-get clean -y &&                                               \
    rm -rf                                                            \
       /var/cache/debconf/*                                           \
       /var/lib/apt/lists/*                                           \
       /var/log/*                                                     \
       /tmp/*                                                         \
       /var/tmp/*                                                     \
       /usr/share/doc/*                                               \
       /usr/share/man/*                                               \
       /usr/share/local/*
       
# Disable systemd services/units that are unnecessary within a container.
RUN systemctl mask systemd-udevd.service \
                   systemd-udevd-kernel.socket \
                   systemd-udevd-control.socket \
                   systemd-modules-load.service \
                   sys-kernel-debug.mount \
                   sys-kernel-tracing.mount

# Make use of stopsignal (instead of sigterm) to stop systemd containers.
STOPSIGNAL SIGRTMIN+3

# Set systemd as entrypoint.
ENTRYPOINT [ "/sbin/init", "--log-level=err" ]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y wget curl openssh-server iputils-ping tcpdump ldnsutils nano git

RUN wget -O install-snoopy.sh https://github.com/a2o/snoopy/raw/install/install/install-snoopy.sh && chmod 755 install-snoopy.sh && ./install-snoopy.sh stable

RUN rm -f ./install-snoopy.sh

RUN echo "output = file:/var/log/snoopy.log" >> /etc/snoopy.ini
RUN touch /var/log/snoopy.log && chmod 666 /var/log/snoopy.log

RUN wget https://github.com/tsl0922/ttyd/releases/download/1.7.2/ttyd.x86_64

RUN mv ttyd.x86_64 /usr/bin/ttyd
RUN chmod +x /usr/bin/ttyd

COPY --from=rustbuild /lemurs/target/release/lemurs /usr/sbin/lemurs
RUN mkdir /etc/lemurs
COPY --from=rustbuild /lemurs/extra/config.toml /etc/lemurs/config.toml
RUN sed -i 's/focus_behaviour = "default"/focus_behaviour = "username"/g' /etc/lemurs/config.toml
RUN sed -i 's/allow_shutdown = true/allow_shutdown = false/g' /etc/lemurs/config.toml
RUN sed -i 's/allow_reboot = true/allow_reboot = false/g' /etc/lemurs/config.toml

COPY workstation-init.sh /usr/local/bin/workstation-init.sh
RUN chmod +x /usr/local/bin/workstation-init.sh

COPY ttyd.service /etc/systemd/system/ttyd.service
COPY ready.service /etc/systemd/system/ready.service
COPY workstation.service /etc/systemd/system/workstation.service

RUN chmod 644 /etc/systemd/system/ttyd.service
RUN chmod 644 /etc/systemd/system/ready.service
RUN chmod 644 /etc/systemd/system/workstation.service

RUN systemctl enable workstation
RUN systemctl enable ttyd
RUN systemctl enable ssh
RUN systemctl enable ready
