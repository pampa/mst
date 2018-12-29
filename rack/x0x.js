/*
 * Simple x0x style trigger sequencer
 */

class x0x {
    constructor() {
        this.patterns = {}
        this.steps    = 0;
    }

    pat(name, pattern, func) {
        this.patterns[name] = {
            pattern: pattern.replace(/[|\s]/g,""),
            func: func === undefined ? this.patterns[name].func : func
        }
    }

    step() {
        Object.keys(this.patterns).map((p) => {
            let { pattern, func } = this.patterns[p];
            let i = this.steps % pattern.length;
            if("-" !== pattern[i]) {
                func(pattern[i]);
            }
        });
        this.steps += 1;
    }

    reset() {
        this.steps = 0;
    }
}

module.exports = x0x;
