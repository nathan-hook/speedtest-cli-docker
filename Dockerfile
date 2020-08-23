```
FROM alpine:3.7

# Modified from: https://gist.github.com/brennentsmith/4958cc8b4f3d99da3a3492604ce4c786

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
CMD ["/scratch/speedtest", "--accept-license", ">", "/dev/null"]
ENTRYPOINT ["/scratch/speedtest", "--format=json"]
```
