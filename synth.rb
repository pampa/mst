require "./midi" 

class Synth
  def initialize(name, sub_name)
    @name     = name
    @sub_name = sub_name
  end

  def hw_port
    Alsa.hw_ports.select { |i| i[:name] == @name && i[:sub_name] == @sub_name }.first[:port]
  end

  def on(type = :all, &block)
    if block_given?
      @yield ||= {}
      @yield[type] = block
    else
      raise "Expecing Block"
    end
  end
  
  def emit(m)
    m.extend Midi
    @yield[:all]  .call(m) if @yield.has_key?(:all)
    @yield[:clock].call(m) if @yield.has_key?(:clock) && m.clock?
    @yield[:note] .call(m) if @yield.has_key?(:note)  && m.note?
  end
end


#def pgm(chan, val)
#	raise "channel must be 1..16" unless (1..16).include?(chan)
#	raise "value must be 0..127" unless (0..127).include?(val)
#	return ((0xC0 | (chan - 1)).chr + val.chr)
#end

#def cc(chan, val1, val2)
#	raise "channel must be 1..16" unless (1..16).include?(chan)
#	raise "value1 must be 0..119" unless (0..119).include?(val1)
#	raise "value2 must be 0..127" unless (0..127).include?(val2)
#	return ((0xB0 | (chan - 1)).chr + val1.chr + val2.chr)
#end

#class Sequencer 
#	def initialize
#		@start = false
#		@click = -1 
#		@time_start = Time.now
#		@time_now   = Time.now
#		@was_click = false	
#	end

#	def <<(n)
#		if n.start?
#			@click = -1 
#			@start = true
#			@time_start = Time.now
#		end

#		if n.stop?
#			@start = false
#		end
#
#		if n.click?
#			@was_click = true
#			return unless @start
#			@time_now = Time.now
#			@click += 1
#		else
#			@was_click = false
#		end
#	end
#
#	def pp
#		return unless @was_click
#		if @click == -1
#			printf("\rBar %-2d Step %-2d %d %-2d %02d:%02d.%02d %s",0,0,0,0,0,0,0,"PAUSED") 
#		else
#			printf("\rBar %-2d Step %-2d %d %-2d %02d:%02d.%02d %s", 
#			       c_bar, 
#			       c_step, 
#			       c_click_in_step, 
#			       c_click,
#			       (@time_now - @time_start) / 60,
#			       (@time_now - @time_start) % 60,
#			       ((@time_now - @time_start) - (@time_now - @time_start).to_i) * 24 + 1,
#			       @start ? "ON AIR" : "PAUSED")
#		end
#	end
#
#	def c_click
#		(@click % 96) + 1
#	end
#	
#	def c_click_in_step
#		((@click % 96) % 6) + 1
#
#	end
#
#	def c_step
#		((@click % 96) / 6) + 1
#
#	end
#
#	def c_bar
#		(@click / 96) + 1
#	end
#
#	def when(h)
#		if h[:bar] == c_bar && h[:step] == c_step && c_click_in_step == 1 
#			yield if @was_click
#		end
#	end
#end
#

