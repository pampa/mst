module PatchBay

    @inputs  = {}
    @outputs = {}

    def self.plug(input,output,block)
        i = self.get_input(input)
        o = self.get_output(output)
        i << Proc.new do |n|
            block.call(n,*o)
        end
    end

    def self.engage!
        ainp = ALSA::Input.new
        @inputs.keys.each { |i| ainp.open(i) }

        ainp.listen do |port,msg|
            msg.extend MidiString
            @inputs[port].each do |p|
                p.call(msg)
            end
        end
    end

    private
    def self.get_input(input)
        @inputs[input] = [] if @inputs[input].nil?
        return @inputs[input]
    end
    
    def self.get_output(output)
        output.each do |o|
            @outputs[o] = ALSA::Output.open(o) if @outputs[o].nil?
        end
        output.collect { |o| @outputs[o] }
    end
end

def plug(c,&block)
    if c.is_a?(String)
        input = c
        output = []
    elsif c.is_a?(Hash)
        input  = c.keys.first
        if c[input].is_a?(Array)
            output = c[input]
        else
            output = [c[input]]
        end
    else
        raise "bad input #{c.inspect}"
    end
    PatchBay.plug(input, output, block)
end

def dont_forget_to_turn_it_on
    PatchBay.engage!
end

alias turn_it_on dont_forget_to_turn_it_on
alias turn_on dont_forget_to_turn_it_on
alias lets_rock dont_forget_to_turn_it_on
alias geronimooo! dont_forget_to_turn_it_on
