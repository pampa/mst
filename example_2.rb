require_relative 'lib/synth'
require_relative 'setup'

#forward all messages from circuit to korg
plug :circuit => :korg

