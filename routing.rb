require_relative 'lib/synth'

synth :circuit do
	name "Circuit", "Circuit MIDI 1"
end

synth :ms20mini do
	name "MS-20 mini", "MS-20 mini MIDI 1"
end

synth :umone do
	name "UM-ONE", "UM-ONE MIDI 1"
end

synth_alias :korg => :ms20mini
synth_alias :nova => :umone

# print note on/off messages
#plug :circuit do |n| 
#	n.pp if n.note?
#end

# forward all messages from circuit to korg
#plug :circuit => :korg

# and the other way round
#plug :korg => :circuit

# play all 3 in unison
#plug :korg => [:circuit,:nova]

# transpose and forward
#plug :korg => :circuit do |n, circuit|
#	n.pitch -= 12 if n.note?
#	circuit << n
#end 


#plug :korg => [:circuit, :nova] do |n, circuit, nova|
#	if n.note?
#		circuit << n
#		circuit << n.copy { |n| n.pitch += 7 }
#		circuit << n.copy { |n| n.chan = 2 }
#		circuit << n.copy { |n| n.pitch += 7; n.chan = 2 }
#		nova << n.copy { |n| n.pitch -= 12 } 
#		nova << n.copy { |n| n.pitch -= 12 + 7 } 
#	end
#end 

#patch_num = 0
#plug :korg => :circuit do |n, circuit|
#	if n.note_on?
#		patch_num = patch_num >= 63 ? 0 : patch_num + 1 
#		circuit << pgm(1, patch_num)
#	end
#end 

seq = Sequencer.new # initialize sequencer
plug :circuit => :circuit do |n, circuit|
	seq << n # feed the midi message to the sequencer to advance the counter
	seq.pp # print current position
	
	# switch to session2 after 6 bars
	seq.when :bar => 5, :step => 16 do
		circuit << pgm(16, 65)
	end
	# play 4 bars of session 2 and switch back to 1 
	seq.when :bar => 9, :step => 16 do
		circuit << pgm(16, 64)
	end
end
