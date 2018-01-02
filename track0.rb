require "./rack/plug"

circ = Plug.new("Circuit", "Circuit MIDI 1")
korg = Plug.new("MS-20 mini", "MS-20 mini MIDI 1")
#euro = Synth.new("UM-ONE",     "UM-ONE MIDI 1")

circ.input :exclude => [:clock] do |m|
  puts m.inspect
end

Plug.start(circ)
