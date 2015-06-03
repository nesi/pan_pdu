#Container for a rack in the Pan cluster in the TDC
class Pan_rack
  attr_accessor :rack_name
  attr_accessor :hosts #Hosts indexed by U
  
  #Create a Pan_rack instance
  # @return [Pan_rack]
  # @param rack_name [String] TDC rack name, for reference.
  # @param pan_host [Pan_host,Array<Pan_host>] A node in the rack, or Array of nodes to initialize the rack host list with.
  def initialize(rack_name, pan_host=nil)
    @rack_name = rack_name
    @hosts = []
    if pan_host.class == Array
      pan_host.each { |ph| @host << ph }
    elsif pan_host != nil
      @hosts << pan_host
    end
  end
  
  #Assignment to the racks @host Array
  # @return [Pan_host] the value passed in
  # @param index [Fixnum] the Array index into the @hosts Array
  # @param value [Pan_host] The host details we want to insert into this position
  def []=(index,value)
    @hosts[index] = value
  end
  
  #Accessing directly into the racks @hosts Array
  # @return [Pan_host] the value passed in
  # @param index [Fixnum] the Array index into the @hosts Array
  def [](index)
    @hosts[index]
  end
  
end
