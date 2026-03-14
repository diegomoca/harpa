(
    // server gui
    s.makeWindow;
    s.window.alwaysOnTop_(true);


    // node tree graph
    ~plotTree = View(nil, Rect(0, 0, 300, 1000)).front.alwaysOnTop_(true);
    s.plotTreeView(parent: ~plotTree);


    // signal meter
    ~meter = ServerMeter.new(s, 0, 2);
    ~meter.window.alwaysOnTop_(true)
)

MIDIClient.init;
MIDIIn.connectAll;

(
    a = [MIDIdef.noteOn(\test, {(freq: {rrand(50, 200)}).play}),
    MIDIdef.noteOn(\test2, {(freq: {rrand(500, 700)}).play})]
)
MIDIFunc.trace(false)


a.do{ |item| item.free }
