/*
 * kick snare hh triplet pattern
 * midi clock from Novation Circuit via x0x 
 * to trigger Circuits drums
 */

const midi    = require("../midi");
const circuit = require("../circuit");

const div     = new (require("../divider"))(); 
const x0x     = new (require("../x0x"))();

const clock  = new midi.Input("Circuit");
const output = new midi.Output("Circuit");

const kick  = new circuit.Drum1(output); 
const snare = new circuit.Drum2(output); 
const hat   = new circuit.Drum3(output); 

clock.on("start", () => { div.start(); });
clock.on("stop",  () => { 
    div.stop();
    x0x.reset();
});
clock.on("clock", () => { 
    div.step();
    output.step();
});

x0x.pat("kick",  "| k----- k----- k----- k----- |", () => {  kick.trig(); });
x0x.pat("snare", "| ------ s----- ------ s----- |", () => { snare.trig(); });
x0x.pat("hat",   "| h-h-h- h-h-h- h-h-h- h-h-h- |", () => {   hat.trig(); });

div.on(4, () => { x0x.step(); });
