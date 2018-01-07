require "./rack/plug"
require "./rack/x0x"

circ = Plug.new("Circuit", "Circuit MIDI 1")
# korg = Plug.new("MS-20 mini", "MS-20 mini MIDI 1")
# euro = Synth.new("UM-ONE",     "UM-ONE MIDI 1")

x0x = X0X.new(circ.out) do |x|
  x.part :a do |x|
    x.drum1 "K--- K--- K--- K--- K--- K--- K--- K-K-"
    x.drum2 "---- S--- ---- S--- ---- S--- ---- S---"
  end
  
  x.part :b do |x|
    x.drum1 "K--- K--- K--- K--- K--- K--- K--- K-K-"
    x.drum2 "---- S--- ---- S--- ---- S--- ---- S---"
    x.drum4 "H-H- H-H- H-H- H-H- H-H- H-H- H-H- H-H-"
  end
  x.song :a, :a, :b, :b
end

circ.input :type => :clock do |m|
  x0x << m
end

Plug.start(circ)
