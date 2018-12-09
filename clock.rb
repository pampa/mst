require "rtmidi"

class Clock 
  def initialize(name)
    @run   = false
    @clock = 0
    @at    = {}

    input = RtMidi::In.new
    port  = input.port_names.index(name)
    if port.nil?
      puts input.port_names.inspect
      raise "no such device #{name}" 
    end

    input.receive_message do | *bytes |
      start if  bytes[0] == 0xFA 
      stop  if  bytes[0] == 0xFC
      clock if (bytes[0] == 0xF8) && @run
    end
    input.open_port(port)
  end

  def clock 
    if @at.keys.include?(@clock) then
      @at[@clock].call
    end
    @clock += 1
  end

  def time
    "#{bar} : #{beat} : #{pos}"
  end

  def at(bar: 1, beat: 1, &block)
    p = ((bar - 1) * 96) + ((beat - 1) * 24)
    @at[p] = block
  end

  def pos
    @clock % 96 + 1
  end

  def bar
    @clock / 96 + 1
  end

  def beat
    @clock % 96 / 24 + 1
  end

  def start
    @run   = true
    @clock = 0
  end
  def stop
    @run   = false
    @clock = 0
  end
end

