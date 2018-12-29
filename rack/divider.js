const Events = require("events");

class Divider extends Events {
    constructor() {
        super();
        this.run   = false;
        this.count = 0;
    }
    start() { 
        this.run = true;
    }
    stop()  {
        this.run = false; this.count = 0;
    }
    clock() {
        if (this.run) {
            this.eventNames().map((e) => {
                let _e = parseInt(e);
                if (this.count % e === 0) { this.emit(e) }
            });
            this.count += 1;
        }
    }
}

module.exports = Divider;
