require_relative 'lib/synth'
require_relative 'setup'

# transpose and forward
plug :korg => :circuit do |n, circuit|
	n.pitch -= 12 if n.note?
	circuit << n
end 

