# Modular Sequencing Toolkit

This is a collection of moderately simple building blocks, that can 
be composed into sequencers of arbitrary complexity to control harware
or software synthesizers, drum machines or anythig else that has midi.

It is based on nodejs javascript interpreter and node-rtmidi bindings.

# Building blocks

The toolkit does not come with an internal clock source. External
midi clock must be patched in e.g. from a drum machine or DAW.

All musical timings within the toolkit are in **steps**. Midi clock is 
24ppq / 24 pulses per querter note, so each 4th note is 24 steps.
8th are 12 steps, 16th are 6 steps, 32th are 3 steps.
Smallest division is 1/96 of a full note. 

You can increase the resolution of the sequencer by doubling the 
incomming clock - e.g. set the drum machine to 200bpm instead of 100,
and adjust the clock divisions for event scheduling accordingly.

## midi.Input

Midi input port, provides clock and transport control messages.

```javascript
const input = new midi.Input("device name");
input.on("start", () => { /* triggers on midi start message */ });
input.on("stop",  () => { /* triggers on midi stop  message */ });
input.on("clock", () => { /* triggers on midi clock message */ });
```

## midi.Output

Midi output port, provides a clocked fifo queue of midi messages.
Messages must be 3 bytes long (e.g. note on/off, cc). Must be 
clocked from a clock source, on each clock step it shifts the 
queue and sends everything enqueued for this step to the assigned
device.

Use it to enqueue midi messages to be sent to a device right away or at
some time in the future. It can be polyphonic - each consecutive 
call to `output.play()` is **zipped** with the current queue, **not appended**
to it.

```javascript
const output = new midi.Output("device name");

input.on("clock", () => { output.step(); });

output.play({note: 60, channel: 1, gate: 96}); // play c3 full note
output.play({note: 64, channel: 1, gate: 48}); // play e3 half note
output.play({note: 67, channel: 1, gate: 24}); // play g3 quarter note
```

This description is already longer than the implementation.
