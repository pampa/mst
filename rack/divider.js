const Events = require("events");

class Divider extends Events {
    constructor() {
        super();
        this.run   = false;
        this.steps = 0;
    }
    start() { 
        this.run = true;
    }
    stop()  {
        this.run = false;
        this.steps = 0;
    }
    step() {
        if (this.run) {
            this.eventNames().map((e) => {
                let _e = parseInt(e);
                if (this.steps % e === 0) { this.emit(e) }
            });
            this.steps += 1;
        }
    }
}

module.exports = Divider;
