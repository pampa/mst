class X0X
  def initialize(out)
    @out   = out
    @run   = false
    @pos   = 0
    @seq   = {}
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
    @song << part 
    yield(self)
    @_part = nil 
  end

  def song(*a)
    @song = a.flatten
  end

  def drum1(s, **kw)
    drum(0x3c, s, **kw)
  end
  
  def drum2(s, **kw)
    drum(0x3e, s, **kw)
  end
  
  def drum3(s, **kw)
    drum(0x40, s, **kw)
  end
  
  def drum4(s, **kw)
    drum(0x41, s, **kw)
  end

  def drum(byte, s, step: 6)
    _s = s.each_byte.reject { |c| [" ", "|"].include?(c.chr) }
    raise "Sequence length #{_s.length * step} % 96 != 0, #{s}" unless (_s.length * step) % 96 == 0
    merge_seq (_s.map do |i|
      if i.chr == "-"
        [nil] * step 
      else
        [[ 0x99, byte, 0x60, 0x89, byte, 0x00 ].map(&:chr).join, [nil] * (step - 1)]
      end
    end).flatten
  end

  def merge_seq(s)
    @seq[@_part] = [nil] * s.length if @seq[@_part].nil?
    raise "seq.length #{@seq[@_part].length} != #{s.length}" unless @seq[@_part].length == s.length
    for i in 0..(@seq[@_part].length - 1)
      if @seq[@_part][i].nil?
        @seq[@_part][i] = s[i]
      elsif !s[i].nil?
        @seq[@_part][i] += s[i]
      end
    end
  end
end
