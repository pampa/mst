/*
 * Naive recursive euclidean pattern generator with pattern inversion
 */

const _ = require('lodash');

const euclid = (pulses, steps, trig = "x", rest = "-" ) => {
    if (pulses > steps) {
        return _.fill(Array(steps), trig).join('').substring(0,steps);
    };

    let a = _.fill(Array(pulses), 1);
    let b = _.fill(Array(steps - pulses), 0);

    let p = _.zipWith(a, b, (a, b) => { 
        if (a === undefined) return [b];
        if (b === undefined) return [a];
        return [a, b];
    });

    const split = (head, tail) => {
        let _h = tail.shift();
        head.push(_h);
        if (tail.length == 0) return { head, tail };
        if (_h.length > tail[0].length) return { head, tail };
        return split(head, tail);
    }

    const combine = ({ head, tail }) => {
        if (tail.length <= 1) return _.flattenDeep([...head, ...tail]);
        let p = _.zipWith(head, tail, (a, b) => {
            if (a == undefined) return b;
            if (b == undefined) return a;
            return [...a, ...b];
        });
        return combine(split([],p));
    }

    p = combine(split([], p));

    trig = trig.split('');
    rest = rest.split('');
    return p.map((i) => {
        if (i === 0) { 
            let _r = rest.shift();
            rest.push(_r);
            return _r;
        }
        if (i === 1) {
            let _t = trig.shift();
            trig.push(_t);
            return _t;
        }
    }).join('');
}

module.exports = euclid;
