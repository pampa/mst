module MidiString
    def note_on?
        self[0].ord & 0xF0 == 0x90 
    end
    def note_off?
        self[0].ord & 0xF0 == 0x80 
    end
    def start?
        self[0].ord == 0xfa
    end
    def stop?
        self[0].ord == 0xfc
    end	
    def click?
        self[0].ord == 0xf8
    end
    def note?
        [0x90,0x80].include?(self[0].ord & 0xF0)
    end

    def chan
        return (self[0].ord & 0xF) + 1 if note?
        raise "not a channel message"
    end

    def chan=(c)
        raise "not a channel message" unless note?
        raise "channel must be 1..16" unless (1..16).include?(c)
        self[0] = (self[0].ord & 0xF0 | (c-1)).chr
    end

    def pitch 
        return self[1].ord if note?
        raise "not a note, pitch not applicable"
    end

    def pitch=(n)
        raise "not a note, pitch not applicable" unless note?
        self[1] = n > 127 ? 127.chr : n.chr
    end

    def velo
        return self[2].ord if note?
        raise "not a note, velocity not applicable"
    end

    def copy
        n = self.clone
        yield(n) if block_given?
        return n
    end

    def pp
        if note_on?
            printf("note on  ch:%-2d %-3d %-3d", chan, pitch, velo)
        elsif note_off?
            printf("note off ch:%-2d %-3d %-3d", chan, pitch, velo)
        elsif start?
            printf("start")
        elsif stop?
            printf("stop")
        elsif click?
            printf("click")
        else
            self.bytes.each { |c| printf "0x%x ", c.ord }
        end
        puts
        return self
    end
end
