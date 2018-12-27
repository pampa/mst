require "rtmidi"

class Clock 
  def initialize(name)
    @run       = false
    @clock_out = []

    input = RtMidi::In.new
    port  = input.port_names.index(name)
    if port.nil?
      puts input.port_names.inspect
      raise "no such device #{name}" 
    end

    input.receive_message do | *bytes |
      begin
        start if  bytes[0] == 0xFA 
        stop  if  bytes[0] == 0xFC
        pulse if (bytes[0] == 0xF8) && @run
      rescue Exception => e
        puts e
        puts e.backtrace
      end
    end
    input.open_port(port)
  end
  
  def pulse
    @clock_out.map(&:pulse)
  end
  
  def start
    @run = true
    @clock_out.map(&:start)
  end
  
  def stop
    @run = false 
    @clock_out.map(&:stop)
  end

  def connect(i)
    @clock_out.push(i)
  end
end

