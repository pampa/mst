module MidiString

    def chan=(c)
        raise "not a channel message" unless note?
        raise "channel must be 1..16" unless (1..16).include?(c)
        self[0] = (self[0].ord & 0xF0 | (c-1)).chr
    end


    def pitch=(n)
        raise "not a note, pitch not applicable" unless note?
        self[1] = n > 127 ? 127.chr : n.chr
    end


    def copy
        n = self.clone
        yield(n) if block_given?
        return n
    end

end
