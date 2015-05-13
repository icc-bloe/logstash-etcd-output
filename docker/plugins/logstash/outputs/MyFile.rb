require "logstash/outputs/base"
require "logstash/namespace"

class LogStash::Outputs::MyFile < LogStash::Outputs::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your logstash config.
  #
  # filter {
  #   foo { ... }
  # }
  config_name "MyFile"

  # New plugins should start life at milestone 1.
  milestone 1

  public
  def register
    # nothing to do
  end # def register

  public
  def receive(event)
	return unless output?(event)
  	@logger.warn("got event", :event => event)
	File.open('/tmp/test.log', 'a') { |file| file.write(event) }
  end
end
