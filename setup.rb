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
