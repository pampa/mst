require "./rack/plug"
require "./rack/x0x"

circ = Plug.new("Circuit", "Circuit MIDI 1")

x0x = X0X.new(circ.out) do |x|
  x.part :a do |p|
    p.drum1 "| KKKK | KKKK |", step: 24
    p.drum2 "| ---- S--- ---- S--- | ---- S--- ---- S--- |"
    p.drum4 "| H-H- H-H- H-H- H-H- | H-H- H-H- H-H- H-H- |"
  end
  x.part :b do |p|
    p.drum1 "| KKKK | KKKK |", step: 24
    p.drum2 "| ---- S--- ---- S--- | ---- S--- ---- S--- |"
    p.drum4 "| H-H-H- H-H-H- H-H-H- H-H-H- | H-H-H- H-H-H- H-H-H- H-H-H- |", step: 4
  end
  a = [:a,:b]
  b = [:b,:a]
  x.song a, b
end

circ.input :type => :clock do |m|
  x0x << m
end

Plug.start(circ)
