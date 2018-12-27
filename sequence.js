const midi = require('midi');
const util = require('./util');

class Sequence {
    constructor(name) {
        this.queue = [];
        this.output = new midi.output();
        util.selectPort(this.output, name);
    }

    pulse() {
        if(this.queue.length === 0) {
            this.next();
        }
        var message = this.queue.shift();
        if(typeof message !== "undefined") {
            this.output.sendMessage(message);
        }
    }

    next() {
        this.queue.push([0x99,0x3c,90]);
        this.queue.push(...Array(23));
    }

    start() {
        this.reset();
        this.next();
    }
    
    stop() {
        this.reset();
    }

    reset() {
        this.queue = [];
    }
}

module.exports = Sequence;
