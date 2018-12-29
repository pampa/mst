const midi   = require('midi');
const util   = require('./util');
const Events = require('events');

class Input extends Events {
    constructor(name) {
        super();
        const input = new midi.input();
       
        input.on('message', (time, message) => {
            /*
             * 0xFA, 250, 0b11111010 - transport start
             * 0xFC, 252, 0b11111100 - transport stop
             * 0xF8, 248, 0b11111000 - clock pulse, 24 pulses per quarter note
             */
            if (message[0] === 0xFA) { this.emit("start"); }
            if (message[0] === 0xFC) { this.emit("stop");  }
            if (message[0] === 0xF8) { this.emit("clock"); }
        });

        util.selectPort(input, name)
        input.ignoreTypes(true, false, true);
    }
}

module.exports = Input;
