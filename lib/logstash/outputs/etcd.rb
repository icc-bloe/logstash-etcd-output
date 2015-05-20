# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "httpclient"
require "json"

class LogStash::Outputs::Etcd < LogStash::Outputs::Base
	
	# This is how you configure this filter from your logstash config.
	#
	# output {
	#   etcd { 
	#			etcd_ip => "127.0.0.1"
	#			etcd_port => 4001
	#			path => "/path/[value_1]/folder/[value_2]"
	#			value_field => "message" (optional, if not set saves entire event as json)
	#		} 
	# }
	
	config_name "etcd"
	
	# configuration settings
	config :etcd_ip, :validate => :string, :required => true
	config :etcd_port, :validate => :number, :required => true
	config :path, :validate => :string, :required => true
	config :value_field, :validate => :string, :required => false
	config :ttl, :validate => :number, :required => false, :default => 0
	
	# New plugins should start life at milestone 1.
	milestone 1
	
	public
	def register
		begin
			@logger.debug("registering etcd output plugin") 
			print_configuration()		
			validate_configuration()
			parse_fields_in_path()
			
			@etcd_connection = create_etcd_connection()
			if(test_if_etcd_connection_works())
				on_connection_success()
			else
				on_connection_error()
			end
			
			@logger.debug("registered etcd output plugin") 
		rescue Exception => e
			@logger.error("Unhandled exception", :exception => e, :stacktrace => e.backtrace)
		end	
	end # def register
	
	private
	def on_connection_error()
		error_text = "Error: could not connect to etcd! Check the settings for errors..."
		@logger.error(error_text)
		raise error_text
	end
	
	private
	def on_connection_success()
		@logger.info("Connection to etcd successful")
	end 
	
	private
	def print_configuration
		@logger.debug("etcd_ip:", :etcd_ip => @etcd_ip)
		@logger.debug("etcd_port:", :etcd_port => @etcd_port)
		@logger.debug("path:", :path => @path)
		@logger.debug("value_field:", :value_field => defined?(@value_field) && @value_field.size > 0 ? @value_field : "{event as json}")
		@logger.debug("TTL:", :TTL => defined?(@ttl) && @ttl > 0 ? @ttl : "{no TTL}")
	end
	
	private
	def validate_configuration
		if @path.size < 1 then validation_error("You must define an etcd-path to write to") end;
		if @etcd_ip.size < 1 then validation_error("You must define the ip of etcd") end;
		if @etcd_port.size < 1 then validation_error("You must define the port of etcd") end;
		if !defined?(@value_field) || @value_field.size < 1
			@save_entire_event = true
		end
	end
	
	private
	def validation_error(text)
		@logger.error(text)
		raise text
	end
	
	private
	def parse_fields_in_path()	
		fields = path.split "/"
		@fields_in_path = []
		fields.each do | field |	
			if field.start_with?('[') && field.end_with?(']')
				@logger.debug("found dynamic field:", :field => field);
				@fields_in_path.push(field[1..-2])
			end
		end
	end
	
	private
	def build_etcd_http_path(path_to_key)
		etcd_path = "http://#{@etcd_ip}:#{@etcd_port.to_s}/v2/keys#{path_to_key}"
		@logger.debug("Accessing etcd-path: #{etcd_path}")
		return etcd_path
	end
	
	protected
	def create_etcd_connection()
		return HTTPClient.new
	end
	
	private
	def is_http_status_between(status_code, lower_bound_inclusive, upper_bound_exclusive)
		return status_code >= lower_bound_inclusive && status_code < upper_bound_exclusive;
	end
	
	private
	def is_http_status_successful(status_code)
		return is_http_status_between(status_code,200,300)
	end
	
	private
	def is_http_status_redirect(status_code)
		return is_http_status_between(status_code,300,400)
	end
	
	private
	def is_http_status_error()
		return is_http_status_between(status_code,400,600)
	end
	
	private
	def test_if_etcd_connection_works		
		begin
			@logger.debug("test if etcd connection works by trying to read children of /")
			response = @etcd_connection.get(build_etcd_http_path('/'))
			@logger.debug("got response", :response => response)
			if !is_http_status_successful(response.status_code)
				raise "Could not access etcd! HTTP Status Code: #{response.status_code}"
			end
			return true 
		rescue Exception => e
			@logger.error("Could not connect to etcd!", :exception => e, :stacktrace => e.backtrace)
			return false;
		end
	end
	
	public
	def receive(event)
		return unless output?(event)
		
		begin
			dynamic_path = build_dynamic_path(event)
			if @save_entire_event
				value = event.to_json
			else
				value = extract_value(event, @value_field)
			end
			path = build_etcd_http_path(dynamic_path)
			save_value(path, value, 0)
		rescue Exception => e
			@logger.error("Unhandled exception", :exception => e, :stacktrace => e.backtrace, :event => event)
		end	
	end
	
	private
	def build_dynamic_path(event)
			@logger.debug("start building dynamic path from: ", :path => @path)
			dynamic_path = @path
			@fields_in_path.each do | dynamic_field |
				@logger.debug("replace dynamic part of path: ", :dynamic_part => dynamic_field)
				field_value = extract_value(event, dynamic_field)
				dynamic_path = dynamic_path.gsub("[" + dynamic_field + "]", field_value.to_s)
				@logger.debug("path is now: ", :path => dynamic_path)
			end
			@logger.debug("built dynamic path: ", :path => dynamic_path)
			return dynamic_path
	end
	
	private
	def extract_value(event, field_name)
		value = event[field_name]
		if value.respond_to?(:iso8601)
			@logger.debug("value is a time, convert to ISO8601 format: ", :value => value)
			value = value.iso8601(3)
		end
		@logger.debug("class is #{value.class.name}")
		@logger.debug("extracted value from event: ", :field_name => field_name, :value => value)
		return value
	end
	
	private
	def save_value(path, value, attempt)
		body = {:value => value}
		if @ttl > 0
			body[:ttl] = @ttl
		end
		response = @etcd_connection.put(path, body);
		if is_http_status_successful(response.status_code)
			@logger.debug("successfully saved value to etcd")
		elsif is_http_status_redirect(response.status_code)
			@logger.debug("got redirect response: try again with new location")
			location = response.header["Location"][0]
			save_value(location, value, attempt+1)
		else
			@logger.error("An error occurred accessing etcd!", :path => path, :value => value, :response_code => response.status_code, :response => response)
		end
	end
end
