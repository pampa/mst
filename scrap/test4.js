/*
 * Replacing x0x patterns at set points in time
 */

const midi    = require("../midi");
const circuit = require("../circuit");

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

x0x.pat("kick", "| K--- k--- K--k k--- |", () => { kick.trig(); });

time.at({bar: 5}, () => {
    time.log();
    x0x.pat("kick", "| K--K --K- --K- K--- |");
});

time.at({bar: 9}, () => {
    time.log();
    x0x.pat("kick","| K--- K-K- --K- K--- |");
});

time.at({bar: 13}, () => {
    time.log();
    x0x.pat("kick", "| K-K- KK-K -K-K |");
});

time.at({bar: 17}, () => {
    time.log();
    x0x.pat("kick", "| K--- ---- ---- ---- |");
});

time.at({bar: 18}, () => {
    time.log();
    x0x.pat("kick", "| K--- ---- K--- ---- |");
});

time.at({bar: 19}, () => {
    time.log();
    x0x.pat("kick", "| K--- K--- K--- K--- |");
});

time.at({bar: 20}, () => {
    time.log();
    x0x.pat("kick", "| K-K- K-K- K-K- K-K- |");
});

time.at({bar: 21}, () => {
    time.log();
    x0x.pat("kick", "| K-K- K-K- KKKK KKKK |");
});

time.at({bar: 22}, () => {
    time.log();
    x0x.pat("kick", "-");
});

div.on(6, () => { x0x.step(); });
