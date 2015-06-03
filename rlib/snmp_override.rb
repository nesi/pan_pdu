#Overrides the ruby snmp modules Manager.walk, to allow non-increasing OIDs
#We see non-increasing OIDS from switches, where the tack on a MAC or IP address to the base OID.
#
module SNMP
  #Manager class from snmplib
  class Manager
    #Overrides walk in the standard SNMP snmp.rb library.
    #Walks a list of ObjectId or VarBind objects using get_next until the response to the first OID in the list reaches the end of its MIB subtree.
    # @param object_list [Array] List of oids we are looking up
    # @param index_column The index_column identifies the column that will provide the index for each row. 
    #        This information is used to deal with “holes” in a table (when a row is missing a varbind for one column). 
    #         A missing varbind is replaced with a varbind with the value NoSuchInstance.
    #         This could be used to instead of this override function, which is a more brute force approach.
    def walk(object_list, index_column=0)
      raise ArgumentError, "expected a block to be given" unless block_given?
      vb_list = @mib.varbind_list(object_list, :NullValue)
      raise ArgumentError, "index_column is past end of varbind list" if index_column >= vb_list.length
      is_single_vb = object_list.respond_to?(:to_str) || object_list.respond_to?(:to_varbind)
      start_list = vb_list
      start_oid = vb_list[index_column].name
      last_oid = start_oid
      loop do
        vb_list = get_next(vb_list).vb_list
        index_vb = vb_list[index_column]
        break if EndOfMibView == index_vb.value
        stop_oid = index_vb.name
        break unless stop_oid.subtree_of?(start_oid)
        last_oid = stop_oid
        if is_single_vb
          yield index_vb
        else
          vb_list = validate_row(vb_list, start_list, index_column)
          yield vb_list
        end
      end
    end

    #Run an SNMP query to retrieve the OID or OIDS passed in.
    # @param hostname [String] host we are querying
    # @param community [String] SNMP password
    # @param ifTable_columns [String, Array<String>] The OIDS we want to retrieve from this switch.
    def self.snmp_walk(hostname, community, ifTable_columns)
      begin
        SNMP::Manager.open(:Host => hostname, :Community => "#{community}", :Version => :SNMPv1) do |manager|
          manager.walk(ifTable_columns) do |row|
            row.each do |vb| 
                oid = vb.name.to_s.split('.')
                yield [oid, vb.value.to_s]
            end
          end
        end
      rescue SignalException => message #We might get an OS level signal. If so, we need to stop
        $stderr.print "#{Signal} #{message}\n"
        exit -1
      rescue Exception => message #Should be a more refined Exception list!
        $stderr.print "(#{hostname}, #{community}, #{ifTable_columns}) Error: #{@name}: #{message}\n"
      end
    end
  end

end
