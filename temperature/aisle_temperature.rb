#!/usr/local/bin/ruby
require 'time'
require_relative '../rlib/configuration.rb'
require_relative '../rlib/pdu39m2816.rb'
require_relative '../rlib/pdu43V6145.rb'
require_relative '../rlib/upload.rb'

@config = Configuration.new
@auth = Configuration.new((@config.auth[0] == '/') ? @config.auth : File.expand_path(File.dirname(__FILE__)) + '/../' + @config.auth)

####TDC Aisle Temperatures#####
b18_temp = Pdu39m2816.current_temperature('pdu-a2-a-u1', @auth.ibm_39m2816_PDU_community)
d18_temp = Pdu39m2816.current_temperature('pdu-a1-b-u3', @auth.ibm_39m2816_PDU_community)
#TDC G18 sensor. Nb. connected to idataplex b.
g18_temp = Pdu39m2816.current_temperature('pdu-b1-d-u3', @auth.ibm_39m2816_PDU_community)
#TDC H18 sensor
h18_temp = Pdu39m2816.current_temperature('pdu-b1-b-u3', @auth.ibm_39m2816_PDU_community)
#
#From d idataplex pdu
b15_temp = Pdu39m2816.current_temperature('pdu-d1-b-u3', @auth.ibm_39m2816_PDU_community)
d15_temp = Pdu39m2816.current_temperature('pdu-d1-b-u5', @auth.ibm_39m2816_PDU_community)
#From d idataplex pdu
g15_temp = Pdu39m2816.current_temperature('pdu-d1-d-u5', @auth.ibm_39m2816_PDU_community)
#From d idataplex pdu
h15_temp = Pdu39m2816.current_temperature('pdu-d1-d-u3', @auth.ibm_39m2816_PDU_community)
#From e idataplex pdu
k15_temp = Pdu39m2816.current_temperature('pdu-e1-b-u3', @auth.ibm_39m2816_PDU_community)

#Print to STDOUT
puts "#{Time.now.strftime("%Y-%m-%dT%H:%M:%S")} B15=#{b15_temp} D15=#{d15_temp} G15=#{g15_temp} H15=#{h15_temp} K15=#{k15_temp} B18=#{b18_temp} D18=#{d18_temp} G18=#{g18_temp} H18=#{h18_temp}"

#Save as CSV
File.open("#{@config.html_directory}/#{@config.html_temperature_directory}/aisle_temp.csv", "w") do |fd|
  fd.puts "0, #{k15_temp}, #{h15_temp}, #{g15_temp}, #{d15_temp}, #{b15_temp}, 0, 0, #{h18_temp}, #{g18_temp}, #{d18_temp}, #{b18_temp}"
end

#Save as Json
File.open("#{@config.html_directory}/#{@config.html_temperature_directory}/aisle_temp.json", "w") do |fd|
  fd.puts "{ \"data\": [0, #{k15_temp}, #{h15_temp}, #{g15_temp}, #{d15_temp}, #{b15_temp}, 0, 0, #{h18_temp}, #{g18_temp}, #{d18_temp}, #{b18_temp}], \"aisle\": [ 'O15', 'K15', 'H15', 'G15', 'D15', 'B15', 'O18', 'K18', 'H18', 'G18', 'D18', 'B18'], \"datetime\": \"#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\"}"
end

#Copy to external web server
Upload::upload_file( "#{@config.html_directory}/#{@config.html_temperature_directory}/aisle_temp.json", 
             "#{@config.remote_html_directory}/#{@config.remote_html_temperature_directory}/aisle_temp.json", 
             @config.remote_www_server, @auth.transfer_ssh_keyfile
           )
Upload::upload_file( "#{@config.html_directory}/#{@config.html_temperature_directory}/aisle_temp.csv", 
            "#{@config.remote_html_directory}/#{@config.remote_html_temperature_directory}/aisle_temp.csv", 
            @config.remote_www_server, @auth.transfer_ssh_keyfile
          )
