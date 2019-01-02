/*
 * midi Input and Output ports
 */

const midi   = require('midi');
const Events = require('events');
const _      = require('lodash');

const selectPort = (ports, name) => {
    let list = listPorts(ports);
    if (name in list) {
        ports.openPort(list[name]);
    } else {
        console.log(list);
        throw new Error("Unknown device " + name);
    }
}

const listPorts = (ports) => {
    let list = {};
    for (let i = 0; i < ports.getPortCount(); i++) {
        list[ports.getPortName(i)] = i;
    }
    return list;
}

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

        selectPort(input, name)
        input.ignoreTypes(true, false, true);
    }
}

class Output {
    constructor(name) {
        this.queue = [];
        this.output = new midi.output();
        selectPort(this.output, name);
    }

    step() {
        let message = this.queue.shift();
        if(message !== undefined) {
            do {
                this.output.sendMessage(message.splice(0,3));
            } while (message.length > 0);
        }
    }

    play({ note, channel = 1, velocity = 90, gate = 0}) {
        let arr = [[0x90 + channel - 1,note,velocity]]
        if (gate !== 0) {
            arr.push(...Array(gate - 1),[0x80 + channel - 1,note,0]);
        }
        this.queue = _.zipWith(this.queue, arr, (a, b) => {
            if (a == undefined) { return b; }
            if (b == undefined) { return a; }
            return [...a, ...b];
        });
    }
}

module.exports = { Input, Output };
