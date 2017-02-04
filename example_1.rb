require_relative 'lib/synth'
require_relative 'setup'

# print note on/off messages
plug :circuit do |n| 
	n.pp if n.note?
end

