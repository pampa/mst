require_relative 'lib/synth'
require_relative 'setup'

# make circuit sequence itself
seq = Sequencer.new # initialize sequencer
plug :circuit => :circuit do |n, circuit|
	seq << n # feed the midi message to the sequencer to advance the counter
	seq.pp # print current position
	
	# switch to session2 after 6 bars
	seq.when :bar => 6, :step => 16 do
		circuit << pgm(16, 65)
	end
	# play 4 bars of session 2 and switch back to 1 
	seq.when :bar => 10, :step => 16 do
		circuit << pgm(16, 64)
	end
end
