require "./rack/plug"

circ = Plug.new("Circuit", "Circuit MIDI 1")
korg = Plug.new("MS-20 mini", "MS-20 mini MIDI 1")
#euro = Synth.new("UM-ONE",     "UM-ONE MIDI 1")

count = 0
run   = false
circ.input :type => :clock do |m|
  if m.start?
    run   = true
    count = 0
  end
  run = false if m.stop?
  if run && m.pulse?
    if count % 24 == 0
      circ.out << [0x99, 0x3c, 0x60].map(&:chr).join
      circ.out << [0x89, 0x3c, 0x00].map(&:chr).join
    end

    if count % (24 / 2) == 0
      circ.out << [0x99, 0x40, 0x60].map(&:chr).join
      circ.out << [0x89, 0x40, 0x00].map(&:chr).join
    end
    count += 1
  end
end

circ.input :type => :note do |m|
  puts m.inspect
end

Plug.start(circ)
