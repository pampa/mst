require "./rack/plug"
require "./rack/x0x"

circ = Plug.new("Circuit", "Circuit MIDI 1")

x0x = X0X.new(circ.out) do |x|
  x.part :a do |x|
    x.drum1 "| KKKK | KKKK |", step: 24
    x.drum2 "| ---- S--- ---- S--- | ---- S--- ---- S--- |"
    x.drum4 "| H-H- H-H- H-H- H-H- | H-H- H-H- H-H- H-H- |"
  end
  x.part :b do |x|
    x.drum1 "| KKKK | KKKK |", step: 24
    x.drum2 "| ---- S--- ---- S--- | ---- S--- ---- S--- |"
    x.drum4 "| H-H-H- H-H-H- H-H-H- H-H-H- | H-H-H- H-H-H- H-H-H- H-H-H- |", step: 4
  end
  a = [:a,:b]
  b = [:b,:a]
  x.song a, b
end

circ.input :type => :clock do |m|
  x0x << m
end

Plug.start(circ)
