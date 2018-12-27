const midi = require('midi');
const util = require('./util');
const _    = require ('lodash');

class Sequence {
    constructor(name) {
        this.queue = [];
        this.output = new midi.output();

        if (this.next === undefined) {
            throw new TypeError("Must override method next");
        }

        util.selectPort(this.output, name);
    }

    pulse() {
        if(this.queue.length === 0) {
            this.next();
        }
        let message = this.queue.shift();
        if(typeof message !== "undefined") {
            do {
                this.output.sendMessage(message.splice(0,3));
            } while (message.length > 0);
        }
    }

    add() {
        this.queue = _.zipWith(this.queue, arguments, (a, b) => {
            if (a == undefined) { return b; }
            if (b == undefined) { return a; }
            return [...a, ...b];
        });
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
