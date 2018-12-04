require "rtmidi"

class Steps
  def initialize(clock:, ppq: 24)
    @run   = false
    @count = 0
    @ppq   = ppq

    input = RtMidi::In.new
    port  = input.port_names.index(clock)
    raise "no such device #{clock}" if port.nil?

    input.receive_message do | *bytes |
      @run = true  if  bytes[0] == 0xFA 
      if  bytes[0] == 0xFC
        @run   = false
        @count = 0
      end
      if (bytes[0] == 0xF8) && @run
        @count += 1
        self.pulse
      end
    end
    input.open_port(port)
  end

  def pulse
    print "\r #{@count}"     
  end
end
