/* 
 * Novation Circuit
 */

const Output = require("./midi").Output;

class Drum {
    constructor(output) {
        this.output = output;
    }

    trig() {
        this.output.play({ note: this.note,
                        channel: 10, 
                       velocity: 90 })
    }
}

class Drum1 extends Drum {
    constructor(output) {
        super(output);
        this.note = 0x3c;
    }
}

class Drum2 extends Drum {
    constructor(output) {
        super(output);
        this.note = 0x3e;
    }
}

class Drum3 extends Drum {
    constructor(output) {
        super(output);
        this.note = 0x40;
    }
}

class Drum4 extends Drum {
    constructor(output) {
        super(output);
        this.note = 0x41;
    }
}

module.exports = { Drum1, Drum2, Drum3, Drum4 };
