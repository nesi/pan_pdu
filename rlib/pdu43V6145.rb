require 'rubygems'
require 'nokogiri'
require 'rexml/document' 
include REXML
require 'snmp'
require_relative 'webbrowser.rb'
require_relative 'snmp_override.rb'

#Queries for IBM 43V6145 PDU, which some queries need to be done through XML query. Some data is available using SNMP.
class Pdu43V6145
  
  #Create a Pdu43V6145 class
  # @return [Pdu43V6145]
  # @param pdu_hostname [String] The pdu we will be querying
  # @param auth_key [String] The pdu's web password 
  def initialize(pdu_hostname, auth_key, mode = :power)
    wb = WebBrowser.new(pdu_hostname)

    begin
    #Login to PDU
      wb.http_session(80) do 
        wb.post_page('login.htm', {'User' => 'ADMIN', 'Password' => auth_key, 'B1' => 'Login'})
      end
      #Fetch the XML data from the PDU
      wb.http_session(80) do
        if mode == :power
          @env = wb.get_page('ibmframe_4.xml')
        else #Then temperature
          @env = wb.get_page('env_status.xml')
        end
      end
      @xml = Nokogiri::XML(@env)

      wb.http_session(80) do 
        wb.get_page('logout_wait.htm')
      end
    rescue Exception => error
      $stderr.puts "Pdu43V6145.new('#{pdu_hostname}', key) error => #{error}"
    end
  end
  
  #Class level function to retrieve the current power being used via SNMP, rather than A web XML request
  # @return [Float] Power being used in KW
  # @param hostname [String] The pdu's hostname
  # @param community [String] The pdu's snmp read community string.
  def self.current_usage_snmp(hostname, community)
    #SNMPv2-SMI::enterprises
    power_usage_amps = 0.0
    SNMP::Manager.snmp_walk(hostname, community, ["1.3.6.1.4.1.2.6.223.8.2.2.1.7"]) do |k,v| #Total power used, since last PDU reset
      power_usage_amps += v.to_f #Should be just the twelve responses
    end
    return (power_usage_amps * 0.230)/1000.0 #In VA/1000 Apparent Power KW
  end
  
  #retrieve the current power usage (point in time)
  # @return [Float] Power being used in KW
  def current_power_usage
    begin
      power_being_used = 0.0

      (1..3).each do |ipdp|
        (1..4).each do |ap|
          power_reading = @xml.xpath("//XMLdata//info8_IPDP#{ipdp}_ap#{ap}")[0].content.to_f
          power_being_used += power_reading #in Watts
        end
      end
  
      return power_being_used/1000.0 #in KW

    rescue #If something is wrong with the data
      return 0.0
    end
  end
  
  #Power used since the PDU was last reset (generally this is since the power was first turned on)
  # @return [Float] KWHours
  def accumulated_power_used
    power_total = 0.0

    begin
      (1..3).each do |ipdp|
        (1..4).each do |eg|
          power_reading = @xml.xpath("//XMLdata//info8_IPDP#{ipdp}_eg#{eg}")[0].content.to_f
          #$stderr.puts "Power Reading Phase #{ipdp} Socket #{eg} Energy #{power_reading}KJ"
          power_total += power_reading
        end
      end
      return power_total/3600.0
      
    rescue #If something is wrong with the data
      return 0.0
    end
  end
  
  #retrieve the current temperature from the sensor attached to the PDU (assuming there is one)
  # @return [Float] Temperature in C, though the PDU can be told to use F.
  def current_temperature
    begin
      return @xml.xpath("//XMLdata//ibmsys_envstat_tempature")[0].content.to_f  
    rescue #If something is wrong with the data
      return 0.0
    end
  end

end