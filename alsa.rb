require "./alsa_ext"

module Alsa
  def self.listen(*s)
    ports = {}
    s.each { |_s| ports[_s.hw_port] = _s }
    input(ports.keys) do |port, msg|
      ports[port].emit(msg)
    end
  end
end
