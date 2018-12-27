class TimeCode
  def initialize(count = 4, note = 4)
    @at = {}
    @clock = 0

    @beat_len = 96 / note
    @bar_len  = @beat_len * count
  end

  def pulse
    unless @at[@clock].nil? 
      @at[@clock].call
    end
    @clock += 1
  end

#  def reset 
#    @clock = 0
#  end

#  alias_method :stop,  :reset
#  alias_method :start, :reset

  def to_s
    pos  = @clock % @bar_len + 1
    bar  = @clock / @bar_len + 1
    beat = @clock % @bar_len / @beat_len + 1
    "#{bar} : #{beat} : #{pos}"
  end

  def at(bar: 1, beat: 1, &block)
    p = ((bar - 1) * @bar_len) + ((beat - 1) * @beat_len)
    @at[p] = block
  end
end

