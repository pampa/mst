/*
 * simple kick snare hh pattern
 * midi clock from Novation Circuit via clock 
 * divider to trigger Circuits drums
 */

const Input   = require("../rack/input");
const Output  = require("../rack/output");
const Divider = require("../rack/divider"); 

const clock   = new Input("Circuit");
const circuit = new Output("Circuit");
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
    circuit.play([0x99,0x3c,90]);
    // play the snare every other beat
    if(snare) { circuit.play([0x99,0x3e,90]); }
    snare = !snare;
});

div.on(12, () => {
    circuit.play([0x99,0x40,90]);
});
