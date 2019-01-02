/*
 * Trying euclidean patterns 
 */

const midi    = require("../midi");
const circuit = require("../circuit");
const euclid  = require("../euclid");

const div   = new (require("../divider"))(); 
const time  = new (require("../time"))(); 
const x0x   = new (require("../x0x"))();

const clock  = new midi.Input("Circuit");
const output = new midi.Output("Circuit");

const kick = new circuit.Drum1(output);

clock.on("start", () => {
    time.start();
    div.start();
});
clock.on("stop",  () => { 
    time.stop();
    div.stop();
    x0x.reset();
});
clock.on("clock", () => { 
    time.step();
    div.step();
    output.step();
});

time.at({bar: 1}, () => {
    time.log("13 by 24");
    x0x.pat("kick", euclid(13,24), () => { kick.trig(); });
});

div.on(6, () => { x0x.step(); });
