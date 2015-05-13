require "logstash/outputs/base"
require "logstash/namespace"

class LogStash::Outputs::Etcd < LogStash::Outputs::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your logstash config.
  #
  # filter {
  #   foo { ... }
  # }
  config_name "etcd"

  # configuration settings
  config :etcd_ip, :validate => :string
  config :etcd_port, :validate => :number

  # New plugins should start life at milestone 1.
  milestone 1

  public
  def register
  @logger.debug("registering etcd output plugin") 
  print_configuration()		
        connection_success = test_if_etcd_connection_works()	
  if(!connection_success)
    print_connection_error()
  else
    print_connection_success()
  end

    @logger.debug("registered etcd output plugin") 
  end # def register

  private
  def print_connection_error()
    @logger.error("Error: could not connect to etcd! Check the settings for errors...")
  end

  private
  def print_connection_success()
  	@logger.debug("Connection to etcd successful")
  end  

  private
  def print_configuration
	@logger.debug("etcd_ip", :etcd_ip => @etcd_ip)
        @logger.debug("etcd_port", :etcd_port => @etcd_port)

  end

  private
  def test_if_etcd_connection_works 
	return false 
  end

  public
  def receive(event)
	return unless output?(event)
  	
	begin
	rescue Exception => e
		@logger.error("Unhandled exception", :event => event, :exception => e, :stacktrace => e.backtrace)
	end

  end
end
