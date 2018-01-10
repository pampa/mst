class Symbol
  def *(n)
    [self] * n
  end
end

class Sequencer 
  def initialize(out)
    @out   = out
    @run   = false
    @pos   = 0
    @track = []
    @parts = {}
    @song  = []
    yield(self)
  end

  def <<(m)
    if m.start?
      @run   = true
      @pos   = 0
    end
    @run = false if m.stop?
    pulse if @run && m.pulse?
  end

  def pulse 
    if @pos >= @track.length
      @pos = 0
      @track = @parts[@song[0]].call
      @song << @song.shift
    end
    _r = @track[@pos]
    @pos += 1
    @out << _r unless _r.nil?
  end

  def part(part,&block)
    @song << part 
    @parts[part] = Proc.new { block.call(self.clone) }
  end

  def song(*a)
    @song = a.flatten
  end

end
