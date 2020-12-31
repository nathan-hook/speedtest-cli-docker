RUN apt-get update \
    && apt-get install -y --no-install-recommends mysql-client \
    && rm -rf /var/lib/apt/lists/*

Install Speedtest-CLI on Docker Alpine Image
sudo apt-get install gnupg1 apt-transport-https dirmngr
export INSTALL_KEY=379CE192D401AB61
# Ubuntu versions supported: xenial, bionic
# Debian versions supported: jessie, stretch, buster
export DEB_DISTRO=$(lsb_release -sc)
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $INSTALL_KEY
echo "deb https://ookla.bintray.com/debian ${DEB_DISTRO} main" | sudo tee  /etc/apt/sources.list.d/speedtest.list
sudo apt-get update
# Other non-official binaries will conflict with Speedtest CLI
# Example how to remove using apt-get
# sudo apt-get remove speedtest-cli
sudo apt-get -y install speedtest


RUN apt-get update && apt-get -y install gnupg1 apt-transport-https dirmngr && export INSTALL_KEY=379CE192D401AB61 && export DEB_DISTRO=$(lsb_release -sc) && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $INSTALL_KEY && echo "deb https://ookla.bintray.com/debian ${DEB_DISTRO} main" | sudo tee  /etc/apt/sources.list.d/speedtest.list && apt-get update && apt-get -y install speedtest




This actually somewhat worked for installing speed test into an alpine docker container.

https://gist.github.com/brennentsmith/4958cc8b4f3d99da3a3492604ce4c786

FROM alpine as build
ENV SPEEDTESTVERSION="1.0.0"
ENV SPEEDTESTARCH="x86_64"
ENV SPEEDTESTPLATFORM="linux"
ENV SCRATCH="/scratch"
ENV TINI_VERSION="v0.18.0"
RUN mkdir ${SCRATCH}
ADD https://ookla.bintray.com/download/ookla-speedtest-${SPEEDTESTVERSION}-${SPEEDTESTARCH}-${SPEEDTESTPLATFORM}.tgz /tmp/speedtest.tgz
RUN tar -xvf /tmp/speedtest.tgz -C ${SCRATCH} && \
    chmod +x ${SCRATCH}/speedtest
ADD https://curl.haxx.se/ca/cacert.pem ${SCRATCH}/etc/ssl/cert.pem
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static ${SCRATCH}/tini
RUN chmod +x ${SCRATCH}/tini
# RUN apk add upx && upx --brute ${SCRATCH}/speedtest ${SCRATCH}/tini

FROM scratch
COPY --from=build /scratch/ /
ENTRYPOINT ["/tini", "-s", "/speedtest", "--"]


Here is my actual Dockerfile...

You don't like where the speedtest directory is and you couldn't figure out what the original ENTRYPOINT command was doing.

FROM alpine:3.7

ENV SPEEDTESTVERSION="1.0.0"
ENV SPEEDTESTARCH="x86_64"
ENV SPEEDTESTPLATFORM="linux"
ENV SCRATCH="/scratch"
ENV TINI_VERSION="v0.18.0"
RUN mkdir ${SCRATCH}
ADD https://ookla.bintray.com/download/ookla-speedtest-${SPEEDTESTVERSION}-${SPEEDTESTARCH}-${SPEEDTESTPLATFORM}.tgz /tmp/speedtest.tgz
RUN tar -xvf /tmp/speedtest.tgz -C ${SCRATCH} && \
    chmod +x ${SCRATCH}/speedtest
ADD https://curl.haxx.se/ca/cacert.pem ${SCRATCH}/etc/ssl/cert.pem
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static ${SCRATCH}/tini
RUN chmod +x ${SCRATCH}/tini
# RUN apk add upx && upx --brute ${SCRATCH}/speedtest ${SCRATCH}/tini

#ENTRYPOINT ["/tini", "-s", "/scratch/speedtest", "--"]
#ENTRYPOINT ["ls", "-al", "/scratch/"]
#ENTRYPOINT ["/scratch/speedtest", "--format=json"]

ENTRYPOINT ["/scratch/tini", "-s", "/scratch/speedtest", "--"]
