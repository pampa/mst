class Time {
    constructor(count = 4, note =4) {
        this.events  = {};
        this.run     = false;
        this.steps   = 0;
        this.beatLen = 96 / note;
        this.barLen  = this.beatLen * count;
    }

    step() {
        if(this.run) {
            Object.keys(this.events).map((k) => {
                if(parseInt(k) === this.steps) {
                    this.events[k]();
                }
            });
            this.steps += 1;
        }
    }

    log(message = "") {
        let pos  = this.steps % this.barLen + 1;
        let bar  = Math.floor(this.steps / this.barLen) + 1;
        let beat = Math.floor(this.steps % this.barLen / this.beatLen) + 1
        console.log(`${bar} : ${beat} : ${pos} ${message}`) 
    }

    start() {
        this.run = true;
    }

    stop() {
        this.run   = false;
        this.steps = 0;
    }

    at({bar = 1, beat = 1}, func) {
        let t = ((bar - 1) * this.barLen) + ((beat - 1) * this.beatLen)
        this.events[t] = func;
    }
}

module.exports = Time;
