require_relative 'lib/synth'

synth :circuit do
	name "Circuit", "Circuit MIDI 1"
end

synth :ms20mini do
	name "MS-20 mini", "MS-20 mini MIDI 1"
end

synth_alias :ms20mini => :korg

# print note on/off messages
plug :circuit do 
	echo if note?
end

# forward all messages from circuit to korg
plug :circuit => :korg

# and the other way round
plug :korg => :circuit

