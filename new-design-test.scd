
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
    // define midi notes to play strings
    var stringKeys = [49, 51, 54, 56, 58, 61, 63, 66, 68, 70, 72];

    // initialize midi
    MIDIClient.init;
    MIDIIn.connectAll;

    // control bus to change the parameter "tigger frequency"
    // and inital values
    ~trigFreqBus = Bus.control(s, 1);
    ~trigFreqBus.value_(0);

    // audio bus to send audio to body
    ~bodyBus = Bus.audio(s, 1);

    // create a group for strings and one for bodies
    // so that the bodies are always under the strings on the server
    ~stringsGroup = Group.new;
    ~bodiesGroup = Group.after(~stringsGroup);

    // array to index voices (number of elements = number of "strings")
    ~keyArr = nil!11;

    // array to index ressonators (number of elements = number of "bodies")
    ~bodyArr = nil!2;

    // SynthDef for individual string
    SynthDef(\string, {
        |out|
        var sig, ampEnv, trigger, trigFreq, impulse;

        // adsr envelope
        ampEnv = Env.adsr(0.01);

        // in for control bus binded to parameter trigger frequency
        trigFreq = In.kr(\trigFreqBus.kr(0), 1);

        // creation of phasor which can be retriggered and convertion to impulses
        // for better implementation inside UGen Trig
        impulse = HPZ1.kr(
            Phasor.kr(\t_retrigger.kr(0), trigFreq * ControlDur.ir, 0, 1, 0)
        ) < 0;

        // actual trigger of the string with two possible activation modes
        // constant impulses or random impulses
        trigger = Trig.kr(Select.kr(\triggerMethod.kr(0), [
            impulse + \t_retrigger.kr,
            Dust.kr(trigFreq)
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

        // cycle through all the string activating keys and execute triggers
        // and releases if input from midi keyboard matches one of them
        stringKeys.do({
            // item is the item in the arrangement stringKeys and count is a counter
            arg item, count;
            if(note == item){
               // create new body if it doesn't exist
                if (~bodyArr[0] == nil, {
                    ~bodyArr.put(0, Synth(\body, [
                        \in, ~bodyBus,
                    ], ~bodiesGroup).onFree({~bodyArr[0] = nil}))
                });
                // create a new voice or retrigger if one already exist
                if(~keyArr[count] == nil, {
                    // create new string synthdef if it doesn't exist
                    ~keyArr.put(count, Synth(\string, [
                        \t_retrigger, 1,
                        \out, ~bodyBus,
                        \triggerMethod, 0,
                        \trigFreqBus, ~trigFreqBus
                    ], ~stringsGroup).onFree({~keyArr[count] = nil}))
                }, {
                    // if it exist, change its parameter
                    ~keyArr.at(count).set(\t_retrigger, 1, \gate, 1)
                })
            };
        });
    });
    MIDIdef.noteOff(\stringGateClose, {
        |vel, note|
        stringKeys.do({
            arg item, count;
            if(note == item){
                // operate only if synthdef exists
                if(~keyArr[count]!= nil, {
                    ~keyArr.at(count).set(\gate, 0)
                })
            };
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
