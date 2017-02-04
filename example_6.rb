require_relative 'lib/synth'
require_relative 'setup'

plug :korg => [:circuit, :nova] do |n, circuit, nova|
	if n.note?
		circuit << n
		circuit << n.copy { |n| n.pitch += 7 }
		circuit << n.copy { |n| n.chan = 2 }
		circuit << n.copy { |n| n.pitch += 7; n.chan = 2 }
		nova << n.copy { |n| n.pitch -= 12 } 
		nova << n.copy { |n| n.pitch -= 12 + 7 } 
	end
end 
