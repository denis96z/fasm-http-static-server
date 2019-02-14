FROM ubuntu:18.10
RUN apt-get update \
    && apt-get install -y fasm

WORKDIR /tmp

COPY . .
COPY ./httpd.conf /etc/httpd.conf

RUN fasm main.asm service \
    && chmod +x service

CMD ./service
