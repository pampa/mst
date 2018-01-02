require_relative "./alsa"

class Plug 
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
      raise "Expecting Block"
    end
  end
  
  def emit(bytes)
    m = Message.new(bytes)
    @yield[:all]  .call(m) if @yield.has_key?(:all)
    @yield[:clock].call(m) if @yield.has_key?(:clock) && m.clock?
    @yield[:note] .call(m) if @yield.has_key?(:note)  && m.note?
  end
end

class Message
  def initialize(bytes)
    byte1 = bytes[0].ord
    @type = :start    if byte1 == 0xfa
    @type = :stop     if byte1 == 0xfc
    @type = :pulse    if byte1 == 0xf8
    @type = :note_on  if byte1 & 0xF0 == 0x90 
    @type = :note_off if byte1 & 0xF0 == 0x80 
  end

  def start?
    @type == :start
  end

  def stop?
    @type == :stop
  end

  def pulse?
    @type == :pulse
  end

  def clock?
    [:pulse,:start,:stop].include?(@type)
  end

  def note?
    [:note_on,:note_off].include?(@type)
  end
end

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
