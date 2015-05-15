# Logstash Output Plugin for etcd

This is a plugin for [Logstash](https://github.com/elasticsearch/logstash).
It lets you write logstash events to [etcd](https://github.com/coreos/etcd).

## Required Software
You need to have the following software installed (Ubuntu 14.04)
- rubygems-integration
- curl
- git
- logstash

## Installation
To install the plugin you need to build a gem from the gemspec file and then install this gem in logstash.
To do this execute this commands:
```
# Clone this repository
git clone https://github.com/icc-bloe/logstash-output-etcd.git
cd logstash-output-etcd
# Build the gem file
gem build logstash-output-etcd.gemspec
# Install the gem-file into logstash
java -jar vendor/jar/jruby-complete-1.7.11.jar -S gem install /path/to/logstash-output-etcd-X.Y.Z.gem
```
