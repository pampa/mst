desc "list midi ports"
task :ports do
    require_relative "boot"
    puts "ALSA Raw MIDI ports"
    puts "==================="
    ALSA.ports.each do |p|
        print "#{p[:in] ? "I" : " "}#{p[:out] ? "O" : " "} #{p[:port]} #{p[:name]}"
        if p[:sub_name].empty?
            puts ""
        else
            puts ", #{p[:sub_name]}"
        end
    end
end

desc "make native deps"
task :make do
	cd "guts"
	sh "ruby extconf.rb"
	sh "make"
end

desc "make clean native deps"
task :clean do
	cd 'guts'
	sh "make clean"
	rm "Makefile"
end
