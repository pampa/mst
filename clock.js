const midi = require('midi');
const util = require('./util');

class Clock {
    constructor(name) {
        this.run      = false;
        this.clockOut = [];
        const input = new midi.input();
       
        const self = this;
        input.on('message', (time, message) => {
            if (message[0] === 0xFA) { self.start(); }
            if (message[0] === 0xFC) { self.stop();  }
            if (message[0] === 0xF8) { self.pulse(); }
        });

        util.selectPort(input, name)
        input.ignoreTypes(true, false, true);
    }

    start () {
        this.run = true;
        this.clockOut.map((i) => { i.start(); });
    }
    
    stop () {
        this.run = false;
        this.clockOut.map((i) => { i.stop(); });
    }
    
    pulse () {
        if (this.run) {
            this.clockOut.map((i) => { i.pulse(); });
        }
    }

    connect(something) {
        this.clockOut.push(something);
    }
}

module.exports = Clock;
