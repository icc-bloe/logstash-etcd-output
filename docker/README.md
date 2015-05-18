## Logstash etcd output development image
This image contains logstash and the tools needed for developing the etcd output plugin. 

### Run container
It is intended to open a bash session into the container so you can modify the files from outside the container and just build/install and run the plugin within the container.

Mount the following paths (in the container):
- /logstash-output-etcd: folder of the plugin source files
- /logstash/logstash.cfg: the logstash configuration to test the plugin

```
docker run -it 
	--name logstash-dev 
	-v `pwd`/..:/logstash-output-etcd 
	-v `pwd`/logstash.cfg:/logstash/logstash.cfg 
	logstash-dev
```

### Helper scripts
The following scripts help you install/build/test your plugin:
- /install_plugin.sh: Builds the gem file and installs the plugin for logstash
- /start.sh: Starts logstash with the configuration in /logstash/logstash.cfg
