# Modular Sequencing Toolkit

This is a collection of moderately simple building blocks, that can 
be composed into sequencers of arbitrary complexity to control harware
or software synthesizers, drum machines or anythig else that has midi.

It is based on nodejs javascript interpreter and node-rtmidi bindings.

# Building blocks

The toolkit does not come with an internal clock source. External
midi clock must be patched in e.g. from a drum machine or DAW.

## rack/input.js

Midi input port, provides clock and transport control messages.

```javascript
const input = new Input("device name");
input.on("start", () => { /* triggers on midi start message */ });
input.on("stop",  () => { /* triggers on midi stop  message */ });
input.on("clock", () => { /* triggers on midi clock message */ });
```

## rack/output.js

Midi output port, provides a clocked fifo queue of midi messages.
Messages must be 3 bytes long (e.g. note on/off, cc). Must be 
clocked from a clock source, on each clock step it shifts the 
queue and sends everything enqueued for this step to the assigned
device.

Use it to enqueue midi messages to be sent to a device right away or at
some time in the future. It can be polyphonic - each consecutive 
call to `output.play()` is _zipped_ with the current queue, _not appended_
to it.

```javascript
const output = new Output("device name");

input.on("clock", () => { output.step(); });

output.play([0x90,60,90],...Array(96 - 1),[0x80,60,0); // play c3 full note
output.play([0x90,64,90],...Array(48 - 1),[0x80,64,0); // play e3 half note
output.play([0x90,67,90],...Array(24 - 1),[0x80,67,0); // play g3 quarter note
```

This description is already longer than the implementation.
