/*
 * simple kick snare hh pattern
 * midi clock from Novation Circuit via clock 
 * divider to trigger Circuits drums
 */

const midi    = require("../midi");
const Divider = require("../divider"); 

const clock   = new midi.Input("Circuit");
const circuit = new midi.Output("Circuit");
const div     = new Divider();

clock.on("start", () => {
    div.start();
});

clock.on("stop", () => {
    div.stop();
});

clock.on("clock", () => {
    div.step();
    circuit.step();
});

let snare = false;
div.on(24, () => {
    circuit.play({ note: 0x3c, channel: 10, velocity: 90 });
    // play the snare every other beat
    if(snare) { 
        circuit.play({ note: 0x3e, channel: 10, velocity: 90 });
    }
    snare = !snare;
});

div.on(12, () => {
    circuit.play({ note: 0x40, channel: 10, velocity: 90 });
});
