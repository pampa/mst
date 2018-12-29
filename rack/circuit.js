// Novation Circuit
const Output = require("./output");

class Circuit extends Output {
    constructor() {
        super("Circuit");
    }

    drum1() {
        this.play([0x99,0x3c,90]);
    }
    
    drum2() {
        this.play([0x99,0x3e,90]);
    }
    
    drum3() {
        this.play([0x99,0x40,90]);
    }
    
    drum4() {
        this.play([0x99,0x41,90]);
    }
}

module.exports = Circuit;
