/*
 * simple kick snare hh pattern
 * midi clock from Novation Circuit via clock 
 * divider to trigger Circuits drums
 */

const midi    = require("../midi");
const Divider = require("../divider"); 

const clock   = new midi.Input("Circuit");
const output  = new midi.Output("Circuit");
const div     = new Divider();

clock.on("start", () => {
    div.start();
});

clock.on("stop", () => {
    div.stop();
});

clock.on("clock", () => {
    div.step();
    output.step();
});

div.on(192, () => {
    output.play({note: 60, channel: 1, gate: 96});
    output.play({note: 64, channel: 1, gate: 48});
    output.play({note: 67, channel: 1, gate: 24});
});
