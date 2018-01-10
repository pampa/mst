require "./rack/plug"
require "./rack/x0x"

circ = Plug.new("Circuit", "Circuit MIDI 1")

x0x = X0X.new(circ.out) do |x|
  x.part :four do |p|
    p.drum1 "| K--- K--- K--- K--- |"
    p.drum2 "| ---- S--- ---- S--- |"
    p.drum4 "| H-H- H-H- H-H- H-H- |"
  end
  
  x.part :clave do |p|
    p.drum1 "| K--K  --K-  --K-  K--- |"
  end

  x.part :bembe do |p|
    p.drum1 "| K-K-  KK-K  -K-K |"
  end

  x.part :shiko do |p|
    p.drum1 "| K---  K-K-  --K-  K---"
  end
  x.song [:four]  * 4,
         [:clave] * 4,
         [:shiko] * 4
end

circ.input :type => :clock do |m|
  x0x << m
end

Plug.start(circ)
