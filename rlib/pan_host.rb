#Hold details of a host in a rack
class Pan_host
  attr_accessor :hostname
  attr_accessor :ipV4_m
  attr_accessor :ipV4_p
  attr_accessor :location
  attr_accessor :ibm_rack_name
  attr_accessor :rack_u
  
  #Create a Pan_host class
  # @return [Pan_host]
  def initialize( hostname, ipV4_p, ipV4_m, location, ibm_rack_name, rack_u )
    @hostname, @ipV4_p, @ipV4_m, @location, @ibm_rack_name, @rack_u = hostname, ipV4_p, ipV4_m, location, ibm_rack_name, rack_u
  end
  
end
