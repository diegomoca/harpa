// MIDIdef to control parameter "trigger frequency"
MIDIdef.cc(\triggerFreq, {
    |val, num|
    ~trigFreqBus.get({
        |busVal|
        if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 20}, {
            ~trigFreqBus.value_(busVal + ((val - 64) * 0.1))
    })
    });
    // ~trigFreqBus.getSynchronous.postln
}, ccNum: 20);

// MIDIdef for parameter trigger duration
MIDIdef.cc(\triggerDur, {
    |val, num|
    ~trigDurBus.get({
        |busVal|
        if(0 < (busVal + ((val - 64) * 0.01)), {~trigDurBus.value_(busVal + ((val - 64) * 0.01))})
    });
    // ~trigDurBus.getSynchronous.postln
}, ccNum: 52);

MIDIdef.cc(\attack1, {
    |val, num|
    ~attack1Bus.get({
        |busVal|
        if(0 < (busVal + ((val - 64) * 0.01)), {~attack1Bus.value_(busVal + ((val - 64) * 0.01))})
    });
    // ~attack1Bus.getSynchronous.postln
}, ccNum: 53);

MIDIdef.cc(\decay1, {
    |val, num|
    ~decay1Bus.get({
        |busVal|
        if(0 < (busVal + ((val - 64) * 0.01)), {~decay1Bus.value_(busVal + ((val - 64) * 0.01))})
    });
    // ~decay1Bus.getSynchronous.postln
}, ccNum: 54);

MIDIdef.cc(\sustain1, {
    |val, num|
    ~sustain1Bus.get({
        |busVal|
        if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 20}, {
            ~sustain1Bus.value_(busVal + ((val - 64) * 0.01))
        })
    });
    // ~sustain1Bus.getSynchronous.postln
}, ccNum: 55);

MIDIdef.cc(\release, {
    |val, num|
    ~release1Bus.get({
        |busVal|
        if(0 < (busVal + ((val - 64) * 0.01)), {~release1Bus.value_(busVal + ((val - 64) * 0.01))})
    });
    // ~release1Bus.getSynchronous.postln
}, ccNum: 56);

MIDIdef.cc(\curve, {
    |val, num|
    ~curve1Bus.get({
        |busVal|
        ~curve1Bus.value_(busVal + ((val - 64) * 0.01))
    });
    // ~curve1Bus.getSynchronous.postln
}, ccNum: 57);

MIDIdef.cc(\curve, {
    |val, num|
    ~curve1Bus.get({
        |busVal|
        ~curve1Bus.value_(busVal + ((val - 64) * 0.01))
    });
    // ~curve1Bus.getSynchronous.postln
}, ccNum: 57);

MIDIdef.cc(\striVol, {
    |val, num|
    ~striVolBus.get({
        |busVal|
        if(-70 < (busVal.ampdb + ((val - 64) * 0.1)) && {(busVal.ampdb + ((val - 64) * 0.1)) < 6}, {
            ~striVolBus.value_((busVal.ampdb + ((val - 64) * 0.15)).dbamp)
        })
    });
    // ~striVolBus.getSynchronous.ampdb.postln
}, ccNum: 21);

MIDIdef.cc(\accent, {
    |val, num|
    ~accentBus.get({
        |busVal|
        if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 1}, {
            ~accentBus.value_(busVal + ((val - 64) * 0.01))
        })
    });
    // ~accentBus.getSynchronous.postln
}, ccNum: 22);

MIDIdef.cc(\striStruct, {
    |val, num|
    ~striStructBus.get({
        |busVal|
        if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 1}, {
            ~striStructBus.value_(busVal + ((val - 64) * 0.01))
        })
    });
    // ~striStructBus.getSynchronous.postln
}, ccNum: 23);

MIDIdef.cc(\striBright, {
    |val, num|
    ~striBrightBus.get({
        |busVal|
        if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 1}, {
            ~striBrightBus.value_(busVal + ((val - 64) * 0.01))
        })
    });
    // ~striBrightBus.getSynchronous.postln
}, ccNum: 24);

MIDIdef.cc(\striDamp, {
    |val, num|
    ~striDampBus.get({
        |busVal|
        if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 1}, {
            ~striDampBus.value_(busVal + ((val - 64) * 0.01))
        })
    });
    // ~striDampBus.getSynchronous.postln
}, ccNum: 25);

MIDIdef.cc(\bodStruct, {
    |val, num|
    ~bodStructBus.get({
        |busVal|
        if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 1}, {
            ~bodStructBus.value_(busVal + ((val - 64) * 0.01))
        })
    });
    ~bodStructBus.getSynchronous.postln
}, ccNum: 26);

MIDIdef.cc(\bodBright, {
    |val, num|
    ~bodBrightBus.get({
        |busVal|
        if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 1}, {
            ~bodBrightBus.value_(busVal + ((val - 64) * 0.01))
        })
    });
    ~bodBrightBus.getSynchronous.postln
}, ccNum: 27);
