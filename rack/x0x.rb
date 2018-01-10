require_relative "./sequencer"

class X0X < Sequencer
  def initialize(*a)
    @drum = {
      :drum1 => 0x3c,
      :drum2 => 0x3e,
      :drum3 => 0x40,
      :drum4 => 0x41
    }
    super(*a)
  end

  def method_missing(meth,*a, **kw)
    if meth.to_s.start_with?("drum")
      drum(@drum[meth], *a, **kw)
    else
      #FIXME raise MethodMissing
      raise "Shit Happens"
    end

  end

  def drum(byte, s, step: 6, velo: 0x30, acc: 0x70)
    _s = s.each_byte.reject { |c| [" ", "|"].include?(c.chr) }
    merge_seq (_s.map do |i|
      if i.chr == "-"
        [nil] * step 
      else
        [[ 0x99, byte, i > 90 ? velo: acc, 0x89, byte, 0x00 ].map(&:chr).join, [nil] * (step - 1)]
      end
    end).flatten
  end

  def merge_seq(s)
    @_seq = [nil] * s.length if @_seq.nil?
    raise "seq.length #{@_seq.length} != #{s.length}" unless @_seq.length == s.length
    for i in 0..(@_seq.length - 1)
      if @_seq[i].nil?
        @_seq[i] = s[i]
      elsif !s[i].nil?
        @_seq[i] += s[i]
      end
    end
    @_seq
  end
end
