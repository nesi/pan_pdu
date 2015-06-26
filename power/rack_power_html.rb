#!/usr/local/bin/ruby
require_relative '../rlib/pdu39m2816.rb'
require_relative '../rlib/pdu43V6145.rb'
require_relative '../rlib/configuration.rb'
require_relative '../rlib/upload.rb'

@config = Configuration.new
@auth = Configuration.new((@config.auth[0] == '/') ? @config.auth : File.expand_path(File.dirname(__FILE__)) + '/../' + @config.auth)

#Save the power value or values to a file.
# @param file [String] Name of the target file
# @param value [Numeric,Array<Numeric>] Either a number, or an array of numbers
def save(filename,value)
  web_base = @config.html_directory + '/' + @config.html_power_directory
  File.open("#{web_base}/#{filename}", "w") do |fd|
    if value.class == Array
      fd.puts "#{value[0]}" if value.length > 0
      (1...value.length).each { |i| fd.puts ",#{value[i]}" }
    else
      fd.puts value
    end
  end
  Upload::upload_file("#{web_base}/#{filename}", "#{@config.remote_html_directory}/#{@config.remote_html_power_directory}/#{filename}", @config.remote_www_server, @auth.transfer_ssh_keyfile)
end

#Save the power value or values to a file.
# @param file [String] Name of the target file
# @param value [Hash<String=>Numeric>] Either a number, or an array of numbers
def to_json(filename,value)
  web_base = @config.html_directory + '/' + @config.html_power_directory
  if value.class == Hash
    File.open("#{web_base}/#{filename}", "w") do |fd|
      fd.puts "{ 'datetime': '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}',\n  'state': {"
      value.each do |k,v|
        fd.puts "    '#{k}': #{v},"
      end
      fd.puts "    'end': ''\n  }\n}"
    end
    Upload::upload_file("#{web_base}/#{filename}", "#{@config.remote_html_directory}/#{@config.remote_html_power_directory}/#{filename}", @config.remote_www_server, @auth.transfer_ssh_keyfile)
  end
end



current_power_usage = 0;
#
#A1 idataplex
#
a_a_watts = Pdu39m2816.current_power_usage('pdu-a1-b-u1', @auth.ibm_39m2816_PDU_community)
a_b_watts = Pdu39m2816.current_power_usage('pdu-a1-b-u3', @auth.ibm_39m2816_PDU_community)
a_c_watts = Pdu39m2816.current_power_usage('pdu-a1-d-u1', @auth.ibm_39m2816_PDU_community)
a_d_watts = Pdu39m2816.current_power_usage('pdu-a1-d-u3', @auth.ibm_39m2816_PDU_community)
a1_watts = (a_a_watts + a_b_watts + a_c_watts + a_d_watts).round
save("a1_kw.txt", a1_watts)
current_power_usage += a1_watts

#
#C1 idataplex (Called B, just to confuse everyone)
#
b_a_watts = Pdu39m2816.current_power_usage('pdu-b1-b-u1', @auth.ibm_39m2816_PDU_community)
b_b_watts = Pdu39m2816.current_power_usage('pdu-b1-b-u3', @auth.ibm_39m2816_PDU_community)
b_c_watts = Pdu39m2816.current_power_usage('pdu-b1-d-u1', @auth.ibm_39m2816_PDU_community)
b_d_watts = Pdu39m2816.current_power_usage('pdu-b1-d-u3', @auth.ibm_39m2816_PDU_community)
b1_watts =  (b_a_watts + b_b_watts + b_c_watts + b_d_watts).round
save("b1_kw.txt", b1_watts)
current_power_usage += b1_watts

#
#C3 idataplex (Called C1 !!!)
#
#c_a_watts = Pdu43V6145.current_usage_snmp('pdu-c1-b-u3', @auth.ibm_43V6145_PDU_community) #currently not responding. Need to visit TDC to fix
c_b_watts = Pdu43V6145.current_usage_snmp('pdu-c1-b-u5', @auth.ibm_43V6145_PDU_community) 
c_a_watts = c_c_watts = Pdu43V6145.current_usage_snmp('pdu-c1-d-u3', @auth.ibm_43V6145_PDU_community) #Duplicating d-u3 onto b-u3 as a temporary fix to b-u3 not responding. Should work, as these pdu's feed to A & B power supplies of same nodes.
c_d_watts = Pdu43V6145.current_usage_snmp('pdu-c1-d-u5', @auth.ibm_43V6145_PDU_community)
c1_watts = (c_a_watts + c_b_watts + c_c_watts + c_d_watts).round
save("c1_kw.txt", c1_watts)
current_power_usage += c1_watts

#
#A4 idataplex (Called D)
#
d_a_watts = Pdu39m2816.current_power_usage('pdu-d1-b-u1', @auth.ibm_39m2816_PDU_community)
d_b_watts = Pdu39m2816.current_power_usage('pdu-d1-b-u3', @auth.ibm_39m2816_PDU_community) 
d_c_watts = Pdu39m2816.current_power_usage('pdu-d1-b-u5', @auth.ibm_39m2816_PDU_community) 
d_d_watts = Pdu39m2816.current_power_usage('pdu-d1-d-u1', @auth.ibm_39m2816_PDU_community) 
d_e_watts = Pdu39m2816.current_power_usage('pdu-d1-d-u3', @auth.ibm_39m2816_PDU_community) 
d_f_watts = Pdu39m2816.current_power_usage('pdu-d1-d-u5', @auth.ibm_39m2816_PDU_community) 
d1_watts = (d_a_watts + d_b_watts + d_c_watts + d_d_watts  + d_e_watts + d_f_watts).round
save("d1_kw.txt", d1_watts)
current_power_usage += d1_watts

#
#A5 idatalex (called E)
#
#10.0.116.150    pdu-e1-d-u3
#10.0.116.151    pdu-e1-d-u5
#10.0.116.152    pdu-e1-b-u3
#10.0.116.153    pdu-e1-b-u5
e_a_watts = Pdu39m2816.current_power_usage('pdu-e1-b-u1', @auth.ibm_39m2816_PDU_community)
e_b_watts = Pdu39m2816.current_power_usage('pdu-e1-b-u3', @auth.ibm_39m2816_PDU_community)
e_c_watts = Pdu39m2816.current_power_usage('pdu-e1-d-u1', @auth.ibm_39m2816_PDU_community)
e_d_watts = Pdu39m2816.current_power_usage('pdu-e1-d-u3', @auth.ibm_39m2816_PDU_community)
e_e_watts = Pdu43V6145.current_usage_snmp('pdu-e1-b-u5', @auth.ibm_43V6145_PDU_community)
e_f_watts = Pdu43V6145.current_usage_snmp('pdu-e1-d-u5', @auth.ibm_43V6145_PDU_community)
e1_watts = (e_a_watts + e_b_watts + e_c_watts + e_d_watts + e_e_watts + e_f_watts).round
save("e1_kw.txt", e1_watts.to_i)
current_power_usage += e1_watts

#
#Rack A2
#
#10.0.116.199    pdu-a2-a-u1
a2_a_watts = Pdu39m2816.current_power_usage('pdu-a2-a-u1', @auth.ibm_39m2816_PDU_community)
#10.0.116.197    pdu-a2-b-u1
a2_b_watts = Pdu43V6145.current_usage_snmp('pdu-a2-b-u1', @auth.ibm_43V6145_PDU_community)
#10.0.116.198    pdu-a2-d-u1
a2_d_watts = Pdu43V6145.current_usage_snmp('pdu-a2-d-u1', @auth.ibm_43V6145_PDU_community)
#10.0.116.180    pdu-a2-c-u1
a2_c_watts = Pdu39m2816.current_power_usage('pdu-a2-c-u1', @auth.ibm_39m2816_PDU_community)
a2_watts = (a2_a_watts + a2_b_watts + a2_c_watts + a2_d_watts).round
#puts "A2 Total Watts #{a_watts.to_i}"
save("a2_kw.txt",a2_watts)
current_power_usage += a2_watts

#
#Rack A3
#
#10.0.116.191    pdu-a3-a-u1
a3_a_watts = Pdu43V6145.current_usage_snmp('pdu-a3-a-u1', @auth.ibm_43V6145_PDU_community)
#10.0.116.189    pdu-a3-b-u1
a3_b_watts = Pdu39m2816.current_power_usage('pdu-a3-b-u1', @auth.ibm_39m2816_PDU_community)
#10.0.116.192    pdu-a3-c-u1
a3_c_watts = Pdu39m2816.current_power_usage('pdu-a3-c-u1', @auth.ibm_39m2816_PDU_community)
#110.0.116.190    pdu-a3-d-u1
a3_d_watts = Pdu39m2816.current_power_usage('pdu-a3-d-u1', @auth.ibm_39m2816_PDU_community)
a3_watts = (a3_a_watts + a3_b_watts + a3_c_watts + a3_d_watts).round
save("a3_kw.txt", a3_watts)
current_power_usage += a3_watts

#
#RACK C2
#
#10.0.116.195    pdu-c2-a-u1
c2_a_watts = Pdu43V6145.current_usage_snmp('pdu-c2-a-u1', @auth.ibm_43V6145_PDU_community)
#10.0.116.193    pdu-c2-b-u1
c2_b_watts = Pdu43V6145.current_usage_snmp('pdu-c2-b-u1', @auth.ibm_43V6145_PDU_community)
#10.0.116.196    pdu-c2-c-u1
c2_c_watts = Pdu43V6145.current_usage_snmp('pdu-c2-c-u1', @auth.ibm_43V6145_PDU_community)
#10.0.116.194    pdu-c2-d-u1
c2_d_watts = Pdu43V6145.current_usage_snmp('pdu-c2-d-u1', @auth.ibm_43V6145_PDU_community)
c2_watts = (c2_a_watts + c2_b_watts + c2_c_watts + c2_d_watts).round
save("c2_kw.txt", c2_watts)
current_power_usage += c2_watts

#
#C4 Rack
#
#Rack doesn't have IP PDUs installed, so we can't retrieve power usage
#10.0.116.160    pdu-c4-d-u1
#10.0.116.161    pdu-c4-b-u1
#10.0.116.162    pdu-c4-c-u1
#10.0.116.163    pdu-c4-a-u1
#puts "C4 doesn't have IP PDUs installed"
c4_watts = 0.0
current_power_usage += c4_watts

#puts
#puts "Total power use (less C4 Rack): #{current_power_usage}"
#puts
save("total_kw.txt", current_power_usage) 
save("all_kw.txt", [a1_watts, b1_watts, c1_watts, d1_watts, e1_watts, a2_watts, a3_watts, c2_watts, c4_watts, current_power_usage])
to_json("current_kw.json", {'a1_kw'=>a1_watts, 'b1_kw'=>b1_watts, 'c1_kw'=>c1_watts, 'd1_kw'=>d1_watts, 'e1_kw'=>e1_watts, 
                        'a2_kw'=>a2_watts, 'a3_kw'=>a3_watts, 'c2_kw'=>c2_watts, 'c4_kw'=>c4_watts, 'total_kw'=>current_power_usage})

