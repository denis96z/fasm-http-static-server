FROM ubuntu:18.10
WORKDIR /tmp
RUN apt-get update \
    && apt-get install -y fasm
COPY . .
RUN fasm main.asm service \
    && chmod +x service
CMD ./service
