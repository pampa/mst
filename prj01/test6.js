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

const kick  = new circuit.Drum1(output);
const snare = new circuit.Drum2(output);
const hat   = new circuit.Drum3(output);

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

x0x.pat("kick",  euclid(4,16),            () => {   kick.trig(); });
x0x.pat("snare", euclid(5,12),            () => {  snare.trig(); });
x0x.pat("hat",   euclid(5,12, "-", "k"), () => {     hat.trig(); });

div.on(6, () => { x0x.step(); });
