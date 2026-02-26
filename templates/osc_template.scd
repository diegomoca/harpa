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

 ~oscClient.sendMsg("/address", "message")

~oscClient.disconnect
