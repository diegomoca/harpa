(
    s.makeWindow();
    s.window.alwaysOnTop_(true);
)

s.boot

s.latency = nil;

// set up osc client
~oscClient = NetAddr("localhost", 57121);

(   
    ~oscRecieve = OSCFunc({
        |msg|
        postln(msg);
    }, '/address')
)

~oscClient.sendMsg("/address/a", "address-a")
~oscClient.sendMsg("/address/b", "address-b")

~oscClient.disconnect
