#!/usr/local/bin/ruby
require_relative '../rlib/configuration.rb'
require_relative '../rlib/pdu39m2816.rb'

@config = Configuration.new
@auth = Configuration.new((@config.auth[0] == '/') ? @config.auth : File.expand_path(File.dirname(__FILE__)) + '/../' + @config.auth)

puts Pdu39m2816.accumulated_power_used(ARGV[0], @auth.ibm_39m2816_PDU_community)


