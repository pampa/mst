class Sequence
  def initialize(name)
    @queue = []
    @midiout = RtMidi::Out.new
    port  = @midiout.port_names.index(name)
    if port.nil?
      puts midiout.port_names.inspect
      raise "no such device #{name}" 
    end
    @midiout.open_port(port)
  end

  def pulse
    steps if @queue.length == 0
    msg = @queue.shift
    @midiout.send_channel_message(*msg) unless msg.nil?
  end

  def steps
    @queue.push([0x99, 0x3c, 90])
    @queue.push(*([nil] * 23))
  end

  def reset
    @queue = []
  end
  
  def start
    reset
    steps
  end

  alias_method :stop,  :reset
end
