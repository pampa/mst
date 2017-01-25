task :default do
	cd "lib"
	sh "ruby extconf.rb"
	sh "make"
end

task :clean do
	cd 'lib'
	sh "make clean"
	rm "Makefile"
end
