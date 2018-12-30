/*
 * kick snare hh triplet pattern
 * midi clock from Novation Circuit via x0x 
 * to trigger Circuits drums
 */

const clock = new (require("../rack/input"))("Circuit");
const circ  = new (require("../rack/circuit"))();
const div   = new (require("../rack/divider"))(); 
const x0x   = new (require("../rack/x0x"))();

clock.on("start", () => { div.start(); });
clock.on("stop",  () => { 
    div.stop();
    x0x.reset();
});
clock.on("clock", () => { 
    div.clock();
    circ.clock();
});

x0x.pat("kick",  "| k----- k----- k----- k----- |", () => { circ.drum1(); });
x0x.pat("snare", "| ------ s----- ------ s----- |", () => { circ.drum2(); });
x0x.pat("hh",    "| h-h-h- h-h-h- h-h-h- h-h-h- |", () => { circ.drum3(); });

div.on(4, () => { x0x.step(); });
