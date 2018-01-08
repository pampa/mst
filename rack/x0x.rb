class X0X
  def initialize(out)
    @out   = out
    @run   = false
    @pos   = 0
    @seq   = {}
    yield(self)
  end

  def <<(m)
    if m.start?
      @run   = true
      @pos   = 0
    end
    @run = false if m.stop?
    step if @run && m.pulse?
  end

  def step
    if @pos >= @seq[@song[0]].length
      @pos = 0
      @song << @song.shift
    end
    _r = @seq[@song[0]][@pos]
    @pos += 1
    @out << _r unless _r.nil?
  end

  def part(part)
    @_part = part
    yield(self)
    @_part = nil 
  end

  def song(*a)
    @song = a.flatten
  end

  def drum1(s)
    drum(0x3c, s)
  end
  
  def drum2(s)
    drum(0x3e, s)
  end
  
  def drum3(s)
    drum(0x40, s)
  end
  
  def drum4(s)
    drum(0x41, s)
  end

  def drum(byte, s)
    _s = s.each_byte.reject { |c| [" ", "|"].include?(c.chr) }
    merge_seq (_s.map do |i|
      if i.chr == "-"
        [nil] * 6
      else
        [[ 0x99, byte, 0x60, 0x89, byte, 0x00 ].map(&:chr).join, [nil] * 5]
      end
    end).flatten
  end

  def merge_seq(s)
    @seq[@_part] = [nil] * s.length if @seq[@_part].nil?
    for i in 0..(@seq[@_part].length - 1)
      if @seq[@_part][i].nil?
        @seq[@_part][i] = s[i]
      elsif !s[i].nil?
        @seq[@_part][i] += s[i]
      end
    end
  end
end
