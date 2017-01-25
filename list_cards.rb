require_relative 'lib/alsa'

puts "List ALSA cards"
puts "==================="
ALSA.cards.each do |c|
	puts "Card #{c[:card]}: #{c[:name]}, #{c[:longname]}"
end

puts "\nList MIDI ports"
puts "==================="
ALSA::Midi.ports.each do |p|
	puts "#{p[:in] ? "I" : " "}#{p[:out] ? "O" : " "} #{p[:port]} #{p[:name]}, #{p[:sub_name]}"
end

