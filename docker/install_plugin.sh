#!/bin/bash

cd /logstash-output-etcd

# Build the gem file
gem build logstash-output-etcd.gemspec

# Install the gem-file into logstash
cd /logstash-1.4.2
export GEM_HOME=vendor/bundle/jruby/1.9
java -jar vendor/jar/jruby-complete-1.7.11.jar -S gem install /logstash-output-etcd/logstash-output-etcd-0.1.0.gem
