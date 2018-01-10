# About

Ruby DSL for sequencing external MIDI gear

# x0x.rb - drum machine pattern sequencer

Basic four to the floor kick snare hihat pattern

```ruby
require "./rack/plug"
require "./rack/x0x"

circ = Plug.new("Circuit", "Circuit MIDI 1")

x0x = X0X.new(circ.out) do |x|
  x.part :a do |p|
    p.drum1 "| K--- K--- K--- K--- | K--- K--- K--- K--- |"
    p.drum2 "| ---- S--- ---- S--- | ---- S--- ---- S--- |"
    p.drum4 "| H-H- H-H- H-H- H-H- | H-H- H-H- H-H- H-H- |"
  end
end

circ.input :type => :clock do |m|
  x0x << m
end

Plug.start(circ)
```
