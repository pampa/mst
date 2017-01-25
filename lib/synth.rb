require_relative 'alsa'

class Synth
	SYNTHS = {} 

	attr_accessor :name, :shortname

	def initialize(tag)
		@tag = tag
		SYNTHS[tag] = self
	end

	def name(name, sub_name)
		@name      = name
		@sub_name  = sub_name
	end

	def is_it?(a)
		@name == a[:name] && @sub_name == a[:sub_name]
	end

	def to_s
		"#{@name} (#{@sub_name})"
	end

	def self.input(tag)
		s = SYNTHS[tag]
		raise "Uknown syth :#{tag}" if s.nil?
		if inp = ALSA::Midi.ports.select { |c| s.is_it?(c) }.first
			return ALSA::Midi::Input.new(inp[:port])
		else
			raise "Did you plug in your #{s}?"
		end
	end
	
	def self.output(tag)
		s = SYNTHS[tag]
		raise "Uknown syth :#{tag}" if s.nil?
		if inp = ALSA::Midi.ports.select { |c| s.is_it?(c) }.first
			return ALSA::Midi::Output.open inp[:port]
		else
			raise "Did you plug in your #{s}?"
		end
	end
end	

def synth(tag,&block)
	Synth.new(tag).instance_exec &block
end

def synth_alias(a)
	a.each do |k,v|
		raise "Unknown synth :#{k}" if Synth::SYNTHS[k].nil?
		Synth::SYNTHS[v] = Synth::SYNTHS[k]
	end
end

class Plug

	def m=(m)
		@m = m
	end

	def echo
		puts @m.inspect
	end

	def note?
		return true if (@m[0].ord & 0xf0) == 0x90
		return true if (@m[0].ord & 0xf0) == 0x80
		return false
	end	
end

def plug(c,&block)
	if c.is_a?(Hash)
		synth_in  = c.keys.first
		synth_out = c[synth_in]
	elsif c.is_a?(Symbol)
		synth_in = c
	else
		raise "Bad plug param #{c.inspect}"
	end

	 in_port = Synth.input  synth_in
	out_port = Synth.output synth_out
	puts in_port.inspect
	puts out_port.inspect
	_plug = Plug.new

	in_port.on do |m|
		_plug.m = m
		if block_given?
			_plug.instance_exec(&block)
			out_port << m unless out_port.nil?
		else
			out_port << m unless out_port.nil?
		end
	end
end

