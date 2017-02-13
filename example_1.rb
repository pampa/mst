require_relative 'boot'

i = ALSA::Input.new

i.open("hw:3,0,0")
i.open("hw:4,0,0")

i.listen do |port, n|
    puts "#{port}, #{n.inspect}" unless n == 0xf8.chr
end

#o = ALSA::Output.open("hw:1,0,0")

#o << 0x90.chr + 0x64.chr + 0x64.chr
#sleep 3
#o << 0x80.chr + 0x64.chr + 0x00.chr

#midi_in  :circuit, "circuit"
#midi_out :circuit, "circuit"
#midi_io  :korg,    "ms20mini"

#plug :circuit => :korg do |n, korg| 
#    n.pp
#    korg << n
#end

#plug :korg do |n| 
#    n.pp
#end
