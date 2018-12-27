require 'coremidi'

class Clock 
  def initialize(name)
    @run       = false
    @clock_out = []

    port  = CoreMIDI::Source.all.select { |s| s.name == name }[0]
    if port.nil?
      CoreMIDI::Source.all.each do |s|
        puts s.name
      end
      raise "no such device #{name}" 
    end

    port.open do | input |
      while true
        data = input.gets
        sleep 0.00000001 if data.empty?
        data.each do |m|
          puts m[:data].inspect
          start if  m[:data][0] == 0xFA 
          stop  if  m[:data][0] == 0xFC
          pulse if (m[:data][0] == 0xF8) && @run
        end
      end
    end
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

