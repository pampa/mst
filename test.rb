require "./alsa"
require "./synth"

circ = Synth.new("Circuit", "Circuit MIDI 1")
#korg = Synth.new("MS-20 mini", "MS-20 mini MIDI 1")
#euro = Synth.new("UM-ONE",     "UM-ONE MIDI 1")

circ.on(:note) do |m|
  m.pp
end

Alsa.listen(circ)
