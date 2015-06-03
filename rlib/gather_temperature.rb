require 'snmp'
require_relative 'snmp_override.rb'

#Container for snmp queries retrieving temperature readings from TDC rack nodes IMM's
class Gather_temperature
  TEMPERATURE='SNMPv2-SMI::enterprises.2.3.51.3.1.1.2.1.3' #should have a trailing .1, but returns nothing if we do?

  #Create a Gather_temperature instance
  # @return [Gather_temperature]
  # @param racks [Pan_racks] collection of Pan_rack records, each holding an array of pan_host records
  # @param snmp_community [String] SNMP read community for the rack node's IMMs.
  def initialize(racks, snmp_community)
    @results = {}
    @racks = racks.racks #racks in TDC Pan Pod, Hashed indexed by TDC rack designation
    @snmp_community = snmp_community
    walk
  end
  
  #Process each rack's hosts, fetching the Ambient temperature
  def walk
    @racks.each do |rack_name, rack| #for each rack in the Pan Pod
      @results[rack_name] = [0] #This is a filler for the First Array element. Rack U's use origin of 1. Arrays use an origin of 0.
      rack.hosts.each_with_index do |host, i| #For each U in the rack, we should have a Pan_host record
        if host == nil #Shouldn't be the case, as we filled in all U during the setup.
          $stderr.puts "Host[#{i}] == nil in Rack #{rack_name}"
          @results[rack_name] << 0
        elsif host.class != Pan_host
          $stderr.puts "Host[#{i}] not a Pan_host record: Rack #{rack_name}"
          @results[rack_name] << 0
        else 
          if i != 0 #No racks have U == 0, so we ignore these. 
            if host.rack_u != i #This isn't a new host, but a multi-U host, that we have already processed. (Assumes hosts labeled by lowest U)
              @results[rack_name] << @results[rack_name][host.rack_u] #Fill in host temperature from the base U of this host
            else
              @results[rack_name] << process_host(host.hostname, host.ipV4_m) #host is an array of values, which we expand into the params.
            end
          end
        end
      end
    end
  end
  
  #SNMP query handler
  # @return [String, 0] Value from the SNMP query, or 0 if this fails
  # @param manager [SNMP::Manager] From an SNMP::Manager.open (or new)
  def get(manager, ifTable_columns)
    manager.walk(ifTable_columns) do |row|
      row.each do |vb| 
        if vb.name.to_s.split('.')[-1] == '1' #Looking for the .1 to indicate the temperature OID.
          return vb.value #Temperature
        end
      end
    end
    return 0 #No temperature.
  end

  #SNMP query wrapper to fetch temperature
  # @return [Fixnum,String] the temperature we fetched from the host (or 0, if we can't contact it)
  # @param hostname [String] Host name of the target node in the rack
  # @param ipmi_ip [String] The host's IMM ip address, which we do use
  def process_host(host_name, ipmi_ip)
    if host_name == nil
      return 0 #No temperature
    else
      begin
        ifTable_columns = [ TEMPERATURE ] #should have a trailing .1, but returns nothing if we do?
        SNMP::Manager.open(:Host => ipmi_ip, :Community => "#{@snmp_community}", :Version => :SNMPv2c) do |manager|
          return get(manager, ifTable_columns) #The temperature
        end
      rescue SignalException => message
        $stderr.print "#{Signal} #{message}\n"
        exit -1
      rescue Exception => message
        $stderr.print "#{host_name} #{message}\n"
        return 0 #No temperature.
      end
    end
  end
  
  #Generate json from the resulting SNMP queries
  # @param file [String] File name to write json output to
  def to_json(file)
    File.open(file,"w") do |fd|
      fd.puts '{'
      fd.puts "\"datetime\": [\"#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\"],"
      @results.each do |result, values|
        fd.print "\"#{result}\": ["
        values.each_with_index do |v,i|
          if i != 0
            fd.print "#{v},"
          end
        end
        fd.puts "],"
      end
      fd.puts '}'
    end
  end
  
end
