#!/usr/local/bin/ruby
require_relative '../rlib/pdu43V6145.rb'
require_relative '../rlib/configuration.rb'

@config = Configuration.new
@auth = Configuration.new((@config.auth[0] == '/') ? @config.auth : File.expand_path(File.dirname(__FILE__)) + '/../' + @config.auth)

puts Pdu43V6145.new(ARGV[0], @auth.ibm_43V6145_PDU, :temperature).current_temperature



