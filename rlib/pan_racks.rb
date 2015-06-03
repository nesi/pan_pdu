require_relative 'pan_host.rb'
require_relative 'pan_rack.rb'

#Cantainer for hosts in the TDC racks.
#  This is really a configuration file, specific to Pan's private network.
#  It is also overkill, as we could pull the data from the hosts file on xcat, or better yet, the xcat DB.
class Pan_racks
  attr_accessor :racks # @!attribute [rw] racks
                       # @return [Pan_rack]
                       # @note indexed by rack name as a String. 
                       #       Rack names are the TDC location names, not the IBM designators.
  
  #Programmatically fill in rack in TDC with host details
  # @return [Pan_hosts] 
  def initialize
    @racks = {}
    #A2 Rack
    rack_b18 = Pan_rack.new('B18', Pan_host.new(nil, nil, nil,'','',0) ) #There is no U0, so this is a filler for 0 indexed Array.
    (1..42).each { |i| rack_b18[i] = Pan_host.new(nil, nil, nil, "TDC-B18-U#{i}", "A2", i) }
    rack_b18[17] = rack_b18[18] = Pan_host.new("xcat", "10.0.101.206", "10.0.116.206", "TDC-B18-U17", "A2", 17) 
    rack_b18[23] = rack_b18[24] = Pan_host.new("transfer", "10.0.101.205", "10.0.116.205", "TDC-B18-U23", "A2", 23) 
    rack_b18[25] = rack_b18[26] = Pan_host.new("loadleveller", "10.0.101.204", "10.0.116.204", "TDC-B18-U25", "A2", 25) 
    rack_b18[27] = rack_b18[28] = rack_b18[29] = rack_b18[30] = Pan_host.new("compute-bigmem-001", "10.0.111.12", "10.0.127.12", "TDC-B18-U27", "A2", 27) 
    rack_b18[35] = rack_b18[36] = rack_b18[37] = rack_b18[38] = Pan_host.new("compute-bigmem-003", "10.0.111.13", "10.0.127.13", "TDC-B18-U35", "A2", 35) 
    rack_b18[39] = rack_b18[40] = rack_b18[41] = rack_b18[42] = Pan_host.new("compute-bigmem-004", "10.0.111.14", "10.0.127.14", "TDC-B18-U39", "A2", 39) 
    (43..48).each { |i| rack_b18[i] = Pan_host.new(nil, nil, nil, '', "A2", i) } 
    @racks[rack_b18.rack_name] = rack_b18
    #A3 Rack
    rack_b15 = Pan_rack.new('B15', Pan_host.new(nil, nil, nil,'','',0)) #There is no U0, so this is a filler for 0 indexed Array.
    (9..42).each { |i| rack_b15[i] = Pan_host.new(nil, nil, nil, "TDC-B15-U#{i}", "A3", i) }
    rack_b15[1] = rack_b15[2] = Pan_host.new("gpfs-a3-001", "10.0.101.207", "10.0.116.207", "TDC-B15-U1", "A3", 1) 
    rack_b15[3] = rack_b15[4] = Pan_host.new("gpfs-a3-002", "10.0.101.208", "10.0.116.208", "TDC-B15-U3", "A3", 3) 
    rack_b15[5] = rack_b15[6] = Pan_host.new("gpfs-a3-003", "10.0.101.209", "10.0.116.209", "TDC-B15-U5", "A3", 5) 
    rack_b15[7] = rack_b15[8] = Pan_host.new("gpfs-a3-004", "10.0.101.210", "10.0.116.210", "TDC-B15-U9", "A3", 7) 
    (43..48).each { |i| rack_b15[i] = Pan_host.new(nil, nil, nil, '', "A3", i) } 
    @racks[rack_b15.rack_name] = rack_b15
    #C2 Rack
    rack_g18 = Pan_rack.new('G18', Pan_host.new(nil, nil, nil,'','',0)) #There is no U0, so this is a filler for 0 indexed Array.
    (1..42).each { |i| rack_g18[i] = Pan_host.new(nil, nil, nil, "TDC-G18-U#{i}", "C2", i) }
    (43..48).each { |i| rack_g18[i] = Pan_host.new(nil, nil, nil, '', "C2", i) } 
    @racks[rack_g18.rack_name] = rack_g18
    #C4 Rack
    rack_g15 = Pan_rack.new('G15', Pan_host.new(nil, nil, nil,'','',0)) #There is no U0, so this is a filler for 0 indexed Array.
    (1..42).each { |i| rack_g15[i] = Pan_host.new(nil, nil, nil, "TDC-G15-U#{i}", "C4", i) }
    rack_g15[39] = rack_g15[40] = Pan_host.new("compute-bigmem-002", "10.0.111.3", "10.0.127.3", "TDC-G15-U39", "C4", 39) 
    (43..48).each { |i| rack_g15[i] = Pan_host.new(nil, nil, nil, '', "C4", i) } 
    @racks[rack_g15.rack_name] = rack_g15
    #O15 Rack
    rack_o15 = Pan_rack.new('O15', Pan_host.new(nil, nil, nil,'','',0)) #There is no U0, so this is a filler for 0 indexed Array.
    (1..48).each { |i| rack_o15[i] = Pan_host.new(nil, nil, nil, "TDC-O15-U#{i}", "O15", i) }
    @racks[rack_o15.rack_name] = rack_o15
    #O18 Rack
    rack_o18 = Pan_rack.new('O18', Pan_host.new(nil, nil, nil,'','',0)) #There is no U0, so this is a filler for 0 indexed Array.
    (1..48).each { |i| rack_o18[i] = Pan_host.new(nil, nil, nil, "TDC-O18-U#{i}", "O18", i) }
    @racks[rack_o18.rack_name] = rack_o18
  
    #A1 Rack
    rack_e18 = Pan_rack.new('E18', Pan_host.new(nil, nil, nil,'','',0))
    (1..42).each { |i| rack_e18[i] = Pan_host.new("compute-a1-#{"%03d"%i}", "10.0.102.#{i}", "10.0.117.#{i}", "TDC-E18-A-U#{i}", "A1", i) }
    rack_e18[43] = Pan_host.new(nil, nil, nil, "TDC-E18-A-U43", "A1", 43) #blank filler
    (44..48).each { |i| rack_e18[i] = Pan_host.new(nil, nil, nil, '', "", i) } 
    @racks[rack_e18.rack_name] = rack_e18
  
    rack_d18 = Pan_rack.new('D18', Pan_host.new(nil, nil, nil,'','',0))  
    rack_d18[1] = Pan_host.new(nil, nil, nil, "TDC-D18-C-U1", "A1", 1) #blank filler
    (43..56).each { |i| rack_d18[i-41] = Pan_host.new("compute-a1-#{"%03d"%i}", "10.0.102.#{i}", "10.0.117.#{i}", "TDC-D18-C-U#{i-41}", "A1", i-41) }
    rack_d18[16] = rack_d18[17] = Pan_host.new("compute-gpu-a1-001", "10.0.102.77", "10.0.117.77", "TDC-D18-C-U16", "A1", 16) 
    rack_d18[18] = rack_d18[19] = Pan_host.new("compute-gpu-a1-002", "10.0.102.78", "10.0.117.78", "TDC-D18-C-U18", "A1", 18) 
    rack_d18[20] = rack_d18[21] = Pan_host.new("compute-gpu-a1-003", "10.0.102.79", "10.0.117.79", "TDC-D18-C-U20", "A1", 20) 
    rack_d18[22] = rack_d18[23] = Pan_host.new("compute-gpu-a1-004", "10.0.102.80", "10.0.117.80", "TDC-D18-C-U22", "A1", 22) 
    (57..76).each { |i| rack_d18[i-33] = Pan_host.new("compute-a1-#{"%03d"%i}", "10.0.102.#{i}", "10.0.117.#{i}", "TDC-D18-C-U#{i-33}", "A1", i-33) }
    (44..48).each { |i| rack_d18[i] = Pan_host.new(nil, nil, nil, '', "", i) } 
    @racks[rack_d18.rack_name] = rack_d18
  
    #B1 Rack
    rack_i18 = Pan_rack.new('I18', Pan_host.new(nil, nil, nil,'','',0))  
    (1..34).each { |i| rack_i18[i] = Pan_host.new("compute-b1-#{"%03d"%i}", "10.0.103.#{i}", "10.0.118.#{i}", "TDC-I18-A-U#{i}", "B1", i) }
    rack_i18[35] = rack_i18[36] = Pan_host.new("compute-gpu-b1-001", "10.0.103.69", "10.0.118.69", "TDC-I18-A-U35", "C1", 35) 
    rack_i18[37] = rack_i18[38] = Pan_host.new("compute-gpu-b1-002", "10.0.103.70", "10.0.118.70", "TDC-I18-A-U37", "C1", 37) 
    rack_i18[39] =  rack_i18[40] = Pan_host.new("compute-gpu-b1-003", "10.0.103.71", "10.0.118.71", "TDC-I18-A-U39", "C1", 39) 
    rack_i18[41] =  rack_i18[42] = Pan_host.new("compute-gpu-b1-004", "10.0.103.72", "10.0.118.72", "TDC-I18-A-U41", "C1", 41) 
    rack_i18[43] = Pan_host.new(nil, nil, nil, "TDC-I18-A-U43", "C1", 43) #blank filler
    (44..48).each { |i| rack_i18[i] = Pan_host.new(nil, nil, nil, '', "", i) } 
    @racks[rack_i18.rack_name] = rack_i18
  
    rack_h18 = Pan_rack.new('H18', Pan_host.new(nil, nil, nil,'','',0))  
    rack_h18[1] = Pan_host.new(nil, nil, nil,  "TDC-H18-C-U1", "C1", 1) #blank filler
    (35..68).each { |i| rack_h18[i-33] = Pan_host.new("compute-b1-#{"%03d"%i}", "10.0.103.#{i}", "10.0.118.#{i}", "TDC-H18-C-U#{i-33}", "B1", i-33) }
    rack_h18[36] =  rack_h18[37] = Pan_host.new("compute-gpu-b1-005", "10.0.103.73", "10.0.118.73", "TDC-H18-C-U36", "C1", 36) 
    rack_h18[38] =  rack_h18[39] = Pan_host.new("compute-gpu-b1-006", "10.0.103.74", "10.0.118.74", "TDC-H18-C-U38", "C1", 38) 
    rack_h18[40] = rack_h18[41] = Pan_host.new("compute-gpu-b1-007", "10.0.103.75", "10.0.118.75", "TDC-H18-C-U40", "C1", 40) 
    rack_h18[42] = rack_h18[43] = Pan_host.new("compute-gpu-b1-008", "10.0.103.76", "10.0.118.76", "TDC-H18-C-U42", "C1", 42) 
    (44..48).each { |i| rack_h18[i] = Pan_host.new(nil, nil, nil, '', "", i) } 
    @racks[rack_h18.rack_name] = rack_h18
  
    #C1 Rack
    rack_h15 = Pan_rack.new('H15', Pan_host.new(nil, nil, nil,'','',0))  
    (1..28).each { |i| rack_h15[i] = Pan_host.new("compute-c1-#{"%03d"%i}", "10.0.104.#{i}", "10.0.119.#{i}", "TDC-H15-A-U#{i}", "C3", i) }
    rack_h15[29] = rack_h15[30] = Pan_host.new("compute-gpu-c1-001", "10.0.104.80", "10.0.119.80", "TDC-H15-A-U29", "C3", 29) 
    rack_h15[31] = rack_h15[32] = Pan_host.new("compute-gpu-c1-002", "10.0.104.81", "10.0.119.81", "TDC-H15-A-U31", "C3", 31) 
    rack_h15[33] = rack_h15[34] = Pan_host.new("compute-cs-001", "10.0.111.10", "10.0.127.10", "TDC-H15-A-U33", "C3", 33) #CS node + empty GPU slot
    rack_h15[35] =  Pan_host.new("compute-stats-002", "10.0.111.6", "10.0.127.6", "TDC-H15-A-U35", "C3", 35)
    rack_h15[36] = Pan_host.new("compute-stats-003", "10.0.111.7", "10.0.127.7", "TDC-H15-A-U36", "C3", 36) 
    rack_h15[37] = Pan_host.new("compute-c1-059", "10.0.104.59", "10.0.119.59", "TDC-H15-A-U37", "C3", 37) #IVY
    rack_h15[38] = Pan_host.new("compute-c1-060", "10.0.104.60", "10.0.119.60", "TDC-H15-A-U38", "C3", 38) #IVY
    (39..43).each { |i| rack_h15[i] = Pan_host.new(nil, nil, nil, "TDC-H15-A-U#{i}", "C3", i) } #blank filler
    (44..48).each { |i| rack_h15[i] = Pan_host.new(nil, nil, nil, '', "", i) } 
    @racks[rack_h15.rack_name] = rack_h15

    rack_i15 = Pan_rack.new('I15', Pan_host.new(nil, nil, nil,'','',0))  
    rack_i15[1] = Pan_host.new(nil, nil, nil, "TDC-I15-C-U1", "C3", 1) #blank filler
    (29..56).each { |i| rack_i15[i-27] = Pan_host.new("compute-c1-#{"%03d"%i}", "10.0.104.#{i}", "10.0.119.#{i}", "TDC-I15-C-U#{i-27}", "C3", i-27) }
    rack_i15[30] = rack_i15[31] = Pan_host.new("compute-gpu-c1-003", "10.0.104.82", "10.0.119.82", "TDC-I15-C-U30", "C3", 30) 
    rack_i15[32] = rack_i15[33] = Pan_host.new("compute-gpu-c1-004", "10.0.104.83", "10.0.119.83", "TDC-I15-C-U32", "C3", 32) 
    rack_i15[34] = Pan_host.new("compute-stats-004", "10.0.111.8", "10.0.127.8", "TDC-I15-C-U34", "C3", 34) 
    rack_i15[35] =  Pan_host.new("compute-stats-005", "10.0.111.9", "10.0.127.9", "TDC-I15-C-U35", "C3", 35)
    rack_i15[36] =  Pan_host.new("compute-c1-057", "10.0.104.57", "10.0.119.57", "TDC-I15-C-U36", "C3", 36) #IVY
    rack_i15[37] =  Pan_host.new("compute-c1-058", "10.0.104.58", "10.0.119.58", "TDC-I15-C-U37", "C3", 37) #IVY
    (38..43).each { |i| rack_i15[i] = Pan_host.new(nil, nil, nil, "TDC-I15-C-U#{i}", "C3", i) } #blank filler
    (44..48).each { |i| rack_i15[i] = Pan_host.new(nil, nil, nil, '', "", i) } #blank filler
    @racks[rack_i15.rack_name] = rack_i15
  
    #D1 Rack
    rack_d15 = Pan_rack.new('D15', Pan_host.new(nil, nil, nil,'','',0))  
    (1..36).each { |i| rack_d15[i] = Pan_host.new("compute-d1-#{"%03d"%i}", "10.0.105.#{i}", "10.0.120.#{i}", "TDC-D15-A-U#{i}", "A4", i) }
    rack_d15[37] = rack_d15[38] = Pan_host.new("compute-gpu-d1-001", "10.0.105.71", "10.0.120.71", "TDC-D15-A-U37", "A4", 37) 
    rack_d15[39] = rack_d15[40] = Pan_host.new("compute-gpu-d1-002", "10.0.105.72", "10.0.120.72", "TDC-D15-A-U39", "A4", 39) 
    rack_d15[41] = rack_d15[42] = Pan_host.new("compute-phi-d1-001", "10.0.105.76", "10.0.120.76", "TDC-D15-A-U41", "A4", 41) 
    rack_d15[43] = Pan_host.new(nil, nil, nil, "TDC-D15-A-U43", "A4", 43) #blank filler
    (44..48).each { |i| rack_d15[i] = Pan_host.new(nil, nil, nil, '', "", i) } 
    @racks[rack_d15.rack_name] = rack_d15
  
    rack_e15 = Pan_rack.new('E15', Pan_host.new(nil, nil, nil,'','',0))  
    rack_e15[1] = Pan_host.new(nil, nil, nil, "TDC-E15-C-U1", "A4", 1) #blank filler
    (37..70).each { |i| rack_e15[i-35] = Pan_host.new("compute-d1-#{"%03d"%i}", "10.0.105.#{i}", "10.0.120.#{i}", "TDC-E15-C-U#{i-35}", "A4", i-35) }
    rack_e15[36] = rack_e15[37] =  Pan_host.new("compute-gpu-d1-003", "10.0.105.73", "10.0.120.73", "TDC-E15-C-U36", "A4", 36)
    rack_e15[38] =  rack_e15[39] = Pan_host.new("compute-gpu-d1-004", "10.0.105.74", "10.0.120.74", "TDC-E15-C-U38", "A4", 38) 
    rack_e15[40] =  rack_e15[41] =  Pan_host.new("build-sn-gpu", "10.0.105.75", "10.0.120.75", "TDC-E15-C-U40", "A4", 40) 
    rack_e15[42] =  rack_e15[43] = Pan_host.new("compute-phi-d1-002", "10.0.105.77", "10.0.120.77", "TDC-E15-C-U42", "A4",43) 
    (44..48).each { |i| rack_e15[i] = Pan_host.new(nil, nil, nil, '', "", i) } 
    @racks[rack_e15.rack_name] = rack_e15
  
    #E1 Rack
    rack_k15 = Pan_rack.new('K15', Pan_host.new(nil, nil, nil,'','',0))  
    (1..22).each { |i| rack_k15[i] = Pan_host.new("compute-e1-#{"%03d"%i}", "10.0.106.#{i}", "10.0.121.#{i}", "TDC-K15-A-U#{i}", "A5", i) }
    (45..62).each { |i| rack_k15[i-22] = Pan_host.new("compute-e1-#{"%03d"%i}", "10.0.106.#{i}", "10.0.121.#{i}", "TDC-K15-A-U#{i-22}", "A5", i-22) } #Ivy
    (41..43).each { |i| rack_k15[i] = Pan_host.new(nil, nil, nil, "TDC-K15-A-U#{i}", "A5", i) } #blank filler
    (41..48).each { |i| rack_k15[i] = Pan_host.new(nil, nil, nil, '', "", i) } 
    @racks[rack_k15.rack_name] = rack_k15

    rack_l15 = Pan_rack.new('L15', Pan_host.new(nil, nil, nil,'','',0))  
    rack_l15[1] = Pan_host.new(nil, nil, nil, "TDC-L15-C-U1", "A5", 1) #blank filler
    (23..44).each { |i| rack_l15[i-21] = Pan_host.new("compute-e1-#{"%03d"%i}", "10.0.106.#{i}", "10.0.121.#{i}", "TDC-L15-C-U#{i-21}", "A5", i-21) }
    (63..82).each { |i| rack_l15[i-39] = Pan_host.new("compute-e1-#{"%03d"%i}", "10.0.106.#{i}", "10.0.121.#{i}", "TDC-L15-C-U#{i-39}", "A5", i-39) } #Ivy
    (44..48).each { |i| rack_l15[i] = Pan_host.new(nil, nil, nil, '', "", i) } 
    @racks[rack_l15.rack_name] = rack_l15

  end
end