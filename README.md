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

## Configuration
The logstash output configuration uses the following parameters:

### etcd_ip
This is the IP of the etcd endpoint where the events should be written to.
Type: string
Example:
```
etcd_ip => "127.0.0.1"
```
Required: yes
Default Value: none

### etcd_port
This is the port of the etcd endpoint where the events should be written to.
Type: Number
Example:
```
etcd_port => 4001
```
Required: yes
Default Value: none

### path
This is the etcd-path where the values should be written to. If you want all your values in a static non-changing path you just write the path of the directory here:
```
path => "/path/where/everything/is/written/to
```

Normally this is not that useful. You can also write into paths where some folders are dependend on a value of the event. These folders/keys must be enclosed in square brackets:
```
path => "/dynamic/path/[event_value1]/static/[event_value2]"
```
In this example the folder written as [event_value1] will be replaced by the value of the field *event_value1* of the event.
And even the key [event_value2] depends on the value of the field *event_value2* of the event.

Type: String
Required: yes
Default Value: none

### value_field
This is the value that should be written to the defined etcd path. The value is taken from the event of the field defined here.
If this value is **not** set, the entire event is saved as json.

Type: String 
Example:
```
# This writes the value of the field *message* to etcd
value_field => "message"
```
Required: No 
Default Value: none


### Example Configuration
The following example configuration can be tested with the generator input:
```
output {
  etcd{
  	etcd_ip => "10.1.42.1"
	etcd_port => 4001
	path => "/test/[host]/[sequence]"
	# value_field => "message"
  }
}
```

