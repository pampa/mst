const selectPort = (ports, name) => {
    let list = listPorts(ports);
    if (name in list) {
        ports.openPort(list[name]);
    } else {
        console.log(list);
        throw new Error("Unknown device " + name);
    }
}

const listPorts = (ports) => {
    let list = {};
    for (let i = 0; i < ports.getPortCount(); i++) {
        list[ports.getPortName(i)] = i;
    }
    return list;
}

module.exports = { selectPort, listPorts }
