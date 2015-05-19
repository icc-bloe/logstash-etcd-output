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
cd /path/to/logstash
export GEM_HOME=vendor/bundle/jruby/1.9
java -jar vendor/jar/jruby-complete-1.7.11.jar -S gem install /path/to/logstash-output-etcd-X.Y.Z.gem
```

## Configuration
The logstash output configuration uses the following parameters:

### etcd_ip
This is the IP of the etcd endpoint where the events should be written to.  
Type: string  
Required: yes  
Default Value: none  

Example:  
```
etcd_ip => "127.0.0.1"
```

### etcd_port
This is the port of the etcd endpoint where the events should be written to.  
Type: Number  
Required: yes  
Default Value: none  

Example:  
```
etcd_port => 4001
```

### path
This is the etcd-path where the values should be written to. If you want all your values in a static non-changing path you just write the path of the directory here:
```
path => "/path/where/everything/is/written/to"
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
Required: No  
Default Value: none  

Example:  
```
# This writes the value of the field 'message' to etcd
value_field => "message"
```

### ttl
You can define a TTL (time to live) value for your keys. After this time is up keys get deleted in etcd.
If attribute is not defined or ttl is < 1, no ttl is used.

Type: Number [in seconds]
Required: No
Default Value: none

Example:
```
# This removes the keys after 10 seconds
ttl => 10
```


### Example Configuration
The following example configuration can be tested with the generator input:
```
output {
  etcd{
  	etcd_ip => "10.1.42.1"
	etcd_port => 4001
	path => "/test/[host]/[sequence]"
	ttl => 10
	# value_field => "message"
  }
}
```

### Date format
If the path or the value field defined contains dates, they are formatted with the ISO8601 format.  
Example date:
```
2015-05-19T13:37:39.164Z
```
