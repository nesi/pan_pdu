require 'snmp'
require_relative 'snmp_override.rb'

#Queries for IBM 39M2816 PDU, which can be queries using SNMP
class Pdu39m2816
  
  #retrieve the current power usage (point in time) via SNMP
  # @return [Float] Power being used in KW
  def self.current_power_usage(hostname, community)
    #SNMPv2-SMI::enterprises
    SNMP::Manager.snmp_walk(hostname, community, ["1.3.6.1.4.1.534.6.6.2.1.3.2.7.1.43"]) do |k,v| #Current power usage in watts
      return v.to_f/1000.0 #There should be just the one
    end
    return 0.0
  end
  
  #retrieve the total power used since the last PDU reset via SNMP
  # @return [Float] Power being used in KW
  def self.accumulated_power_used(hostname, community)
     SNMP::Manager.snmp_walk(hostname, community, ["1.3.6.1.4.1.534.6.6.2.1.3.2.7.1.54"]) do |k,v| #Total power used, since last PDU reset
      return v.to_f #Should be just the one response 
    end
    return 0.0
  end
  
  #Retrieve the temperature from the sensor attached to the PDU.
  # @return [Float] Temperature in C (Though the PDU can be configured to send in F)
  def self.current_temperature(hostname,community)
    SNMP::Manager.snmp_walk(hostname, community, ["SNMPv2-SMI::enterprises.534.6.6.2.1.4.1.1.2"]) do |k,v| #Dropped the .0, as ruby walk doesn't like single matches in the walk.
      return v.to_f
    end
  end

end
