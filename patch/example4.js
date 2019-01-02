/*
 * Replacing x0x patterns at set points in time
 */

const clock = new (require("../rack/input"))("Circuit");
const circ  = new (require("../rack/circuit"))();
const div   = new (require("../rack/divider"))(); 
const time  = new (require("../rack/time"))(); 
const x0x   = new (require("../rack/x0x"))();

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
    circ.step();
});

x0x.pat("kick", "| K--- k--- K--k k--- |", () => { circ.drum1(); });

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
