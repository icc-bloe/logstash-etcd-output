FROM ubuntu:14.04

# install required packages
RUN apt-get update && apt-get install -y \
  openjdk-7-jre \
  make \
  git \
  wget \
  rubygems-integration \
  supervisor && \
  mkdir -p /var/log/supervisor

ADD logstash-1.4.2.tar.gz /logstash-1.4.2.tar.gz
ADD logstash.cfg /logstash/logstash.cfg
ADD start.sh /start.sh

CMD /bin/bash
