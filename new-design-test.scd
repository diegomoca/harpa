
// testing gui
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

// MIDI debug
MIDIFunc.trace(false)

(
    // initialize midi
    MIDIClient.init;
    MIDIIn.connectAll;

    // control bus to change the parameter "tigger frequency"
    // and inital values
    ~trigFreqBus = Bus.control(s, 1);
    ~trigFreqBus.value_(10);

    // audio bus to send audio to body
    ~bodyBus = Bus.audio(s, 1);

    // array to index voices (number of elements = number of "strings")
    ~keyArr = [nil];
    // array to index ressonators (number of elements = number of "bodies")
    ~bodyArr = [nil];

    // SynthDef for individual string
    SynthDef(\string, {
        |out|
        var sig, ampEnv, trigger, trigFreq;

        ampEnv = Env.adsr(0.01);
        trigFreq = In.kr(\trigFreqBus.kr(0), 1);

        trigger = Trig.kr(Select.kr(\triggerMethod.kr(0), [
            Impulse.kr(trigFreq) + \t_retrigger.kr(1),
            Dust.kr(trigFreq) + \t_retrigger.kr(1)
        ]), \trigDur.kr(0.01));
        
        sig = StringVoice.ar(trigger, 1, 300) * EnvGen.kr(ampEnv, \gate.kr(1), doneAction: 2);

        Out.ar(out, sig)
    }).add;

    // SynthDef for body or resonator
    SynthDef(\body, {
        |in|
        var sig;

        sig = In.ar(in, 1);
        sig = Resonator.ar(sig)!2;

        DetectSilence.ar(sig, doneAction: 2);
        Out.ar(0, sig)
    }).add;

    // MIDIDefs to open and close string's ADSR
    // and to create a new body in case it doesn't exist
    MIDIdef.noteOn(\stringGateOpen,{
        |vel, note|
        // create new body if it doesn't exist
        if (~bodyArr[0] == nil, {
            ~bodyArr.put(0, Synth(\body, [\in, ~bodyBus]).onFree({~bodyArr[0] = nil}))
        });
        // create a new voice or retrigger if one already exist
        if(~keyArr[0] == nil, {
            // create new string synthdef if it doesn't exist
            ~keyArr.put(0, Synth(\string, [
                \out, ~bodyBus,
                \triggerMethod, 0,
                \trigFreqBus, ~trigFreqBus
            ]).onFree({~keyArr[0] = nil}))
        }, {
            // if it exist, change its parameter
            ~keyArr.at(0).set(\t_retrigger, 1)
        })
    });
    MIDIdef.noteOff(\stringGateClose, {
        |vel, note|
        // operate only if synthdef exists
        if(~keyArr[0]!= nil, {
            ~keyArr.at(0).set(\gate, 0)
        })
    });

    // MIDIdef to control parameter "trigger frequency"
    MIDIdef.cc(\paramChange, {
        |val, num|

        ~trigFreqBus.get({
            |busVal|
            if(0 < (busVal + (val - 64 * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 20}, {
                ~trigFreqBus.value_(busVal + (val - 64 * 0.1))
        })
        });
        ~trigFreqBus.getSynchronous.postln
    }, ccNum: 27)
)



