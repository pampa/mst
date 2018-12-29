const midi         = require('midi');
const util         = require('./util');
const _            = require('lodash');

class Output {
    constructor(name) {
        this.queue = [];
        this.output = new midi.output();
        util.selectPort(this.output, name);
    }

    clock() {
        let message = this.queue.shift();
        if(message !== undefined) {
            do {
                this.output.sendMessage(message.splice(0,3));
            } while (message.length > 0);
        }
    }

    play() {
        this.queue = _.zipWith(this.queue, arguments, (a, b) => {
            if (a == undefined) { return b; }
            if (b == undefined) { return a; }
            return [...a, ...b];
        });
    }
}

module.exports = Output;
