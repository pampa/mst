require_relative 'boot'

plug "hw:3,0,0" => "hw:4,0,0" do |n, korg| 
    korg << n
end

plug "hw:3,0,0" do |n| 
    unless n.click? 
        print "circuit "
        n.pp
    end
end

plug "hw:4,0,0" do |n| 
    print "korg "
    n.pp
end

plug "hw:4,0,0" => ["hw:3,0,0","hw:4,0,0"] do |n, circuit, korg| 
    circuit << n
end

dont_forget_to_turn_it_on
