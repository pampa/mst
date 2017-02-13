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
		raise "Uknown synth :#{tag}" if s.nil?
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
		raise "Unknown synth :#{v}" if Synth::SYNTHS[v].nil?
		Synth::SYNTHS[k] = Synth::SYNTHS[v]
	end
end

def pgm(chan, val)
	raise "channel must be 1..16" unless (1..16).include?(chan)
	raise "value must be 0..127" unless (0..127).include?(val)
	return ((0xC0 | (chan - 1)).chr + val.chr)
end

def cc(chan, val1, val2)
	raise "channel must be 1..16" unless (1..16).include?(chan)
	raise "value1 must be 0..119" unless (0..119).include?(val1)
	raise "value2 must be 0..127" unless (0..127).include?(val2)
	return ((0xB0 | (chan - 1)).chr + val1.chr + val2.chr)
end

class Sequencer 
	def initialize
		@start = false
		@click = -1 
		@time_start = Time.now
		@time_now   = Time.now
		@was_click = false	
	end

	def <<(n)
		if n.start?
			@click = -1 
			@start = true
			@time_start = Time.now
		end

		if n.stop?
			@start = false
		end

		if n.click?
			@was_click = true
			return unless @start
			@time_now = Time.now
			@click += 1
		else
			@was_click = false
		end
	end

	def pp
		return unless @was_click
		if @click == -1
			printf("\rBar %-2d Step %-2d %d %-2d %02d:%02d.%02d %s",0,0,0,0,0,0,0,"PAUSED") 
		else
			printf("\rBar %-2d Step %-2d %d %-2d %02d:%02d.%02d %s", 
			       c_bar, 
			       c_step, 
			       c_click_in_step, 
			       c_click,
			       (@time_now - @time_start) / 60,
			       (@time_now - @time_start) % 60,
			       ((@time_now - @time_start) - (@time_now - @time_start).to_i) * 24 + 1,
			       @start ? "ON AIR" : "PAUSED")
		end
	end

	def c_click
		(@click % 96) + 1
	end
	
	def c_click_in_step
		((@click % 96) % 6) + 1

	end

	def c_step
		((@click % 96) / 6) + 1

	end

	def c_bar
		(@click / 96) + 1
	end

	def when(h)
		if h[:bar] == c_bar && h[:step] == c_step && c_click_in_step == 1 
			yield if @was_click
		end
	end
end

module MidiString
	def note_on?
		self[0].ord & 0xF0 == 0x90 
	end
	def note_off?
		self[0].ord & 0xF0 == 0x80 
	end
	def start?
		self[0].ord == 0xfa
	end
	def stop?
		self[0].ord == 0xfc
	end	
	def click?
		self[0].ord == 0xf8
	end
	def note?
		[0x90,0x80].include?(self[0].ord & 0xF0)
	end

	def chan
		return (self[0].ord & 0xF) + 1 if note?
		raise "not a channel message"
	end
	
	def chan=(c)
		raise "not a channel message" unless note?
		raise "channel must be 1..16" unless (1..16).include?(c)
		self[0] = (self[0].ord & 0xF0 | (c-1)).chr
	end

	def pitch 
		return self[1].ord if note?
		raise "not a note, pitch not applicable"
	end
	
	def pitch=(n)
		raise "not a note, pitch not applicable" unless note?
		self[1] = n > 127 ? 127.chr : n.chr
	end

	def velo
		return self[2].ord if note?
		raise "not a note, velocity not applicable"
	end

	def copy
		n = self.clone
		yield(n) if block_given?
		return n
	end

	def pp
		if note_on?
			printf("note on  ch:%-2d %-3d %-3d", chan, pitch, velo)
		elsif note_off?
			printf("note off ch:%-2d %-3d %-3d", chan, pitch, velo)
		elsif start?
			printf("start")
		elsif stop?
			printf("stop")
		elsif click?
			printf("click")
		else
			self.bytes.each { |c| printf "0x%x ", c.ord }
		end
		puts
		return self
	end
end
	

def plug(c,&block)
	if c.is_a?(Hash)
		synth_in  = c.keys.first
		if c[synth_in].is_a?(Symbol)
			synth_out = [Synth.output(c[synth_in])]
		elsif c[synth_in].is_a?(Array)
			synth_out = c[synth_in].collect { |o| Synth.output(o) }
		else
			raise "bad output synth #{c[synth_in].inspect}"
		end
	elsif c.is_a?(Symbol)
		synth_in = c
	else
		raise "Bad plug param #{c.inspect}"
	end
	synth_in = Synth.input  synth_in
	synth_in.on do |m|
		if block_given? then
			m.extend MidiString
			yield(m,*synth_out)
		else
			synth_out.each { |s| s << m }
		end
	end
end

