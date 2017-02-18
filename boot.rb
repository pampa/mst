
if RUBY_PLATFORM =~ /linux/i && RUBY_PLATFORM =~ /x86_64/i
    require_relative "guts/alsa.so"
else
    raise "I'm sorry Dave, I'm afraid I can't do that. Don't know how to run on #{RUBY_PLATFORM}"
end

require_relative "guts/midistring"
require_relative "guts/patchbay"
