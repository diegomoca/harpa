
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

// initialization
(
    s.latency = nil;
    // set up osc client
    ~oscClient = NetAddr("localhost", 57121);
)

// MIDI debug
MIDIFunc.trace(false)

(
    // define midi notes to play strings
    var stringKeys = [49, 51, 54, 56, 58, 61, 63, 66, 68, 70, 72];

    // initial string parameters
    // tuning (traditional pentatonic scale)
    var striFreq = [100, 112.5, 126.5625, 150.0, 168.75, 200.0, 225.0, 253.125, 300.0, 337.5, 400.0],
        striVol = 0.2!11,
        accent = 0.5!11,
        striStruct = 0.1!11,
        striBright = 0.2!11,
        striDamp = 0.8!11,
        // initial body parameters
        bodVol = [1, 0.5],
        bodFreq = [12.5, 400],
        position = 0.5!2,
        resolution = 50!2,
        bodStruct = 0.2!2,
        bodBright = 0!2,
        bodDamp = [0.8, 0.2];

    // OSC function to receive frequencies from python
    ~frequenciesRecieve = OSCFunc({
        |msg|
        postln(msg[1..]);
        striFreq = msg[1..];
        striFreq.do({
            |item, count|
            ~keyArr[count].set(\striFreq, item)
        })
    }, '/freqs');

    // initialize midi
    MIDIClient.init;
    MIDIIn.connectAll;

    // control bus to change the parameter "tigger frequency"
    // and inital values
    ~trigFreqBus = Bus.control(s, 1);
    ~trigFreqBus.value_(0);

    // audio bus to send string to 2 stereo bodies
    ~bodyBus = Bus.audio(s, 4);

    // create a group for strings and one for bodies
    // so that the bodies are always under the strings on the server
    ~stringsGroup = Group.new;
    ~bodiesGroup = Group.after(~stringsGroup);

    // array to index voices (number of elements = number of "strings")
    ~keyArr = nil!11;

    // array to index ressonators (number of elements = number of "bodies")
    ~bodyArr = nil!2;


    // SynthDefs /////////////////////////////////////////////////////////////////////////


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
        
        // actual string synthesizer
        sig = StringVoice.ar(
            trigger, 1, \striFreq.kr(300), \accent.kr(0.5),
            \striStruct.kr(0.5), \striBright.kr(0.5), \striDamp.kr(0.5)
        ) * EnvGen.kr(ampEnv, \gate.kr(1), doneAction: 2);

        // pan and clone stereo signal to send to 2 bodies
        sig = PanAz.ar(2, sig, \panning.kr(0.0));
        sig = sig ++ sig;

        // mix to different bodies
        // multiply the first two amplitudes by the first value
        sig[0] = sig[0] * ((1 - \bodySelect.kr(0.0)) / 2);
        sig[1] = sig[1] * ((1 - \bodySelect.kr(0.0)) / 2);
        // multiply the second two amplitudes by the second value
        sig[2] = sig[2] * ((1 + \bodySelect.kr(0.0)) / 2);
        sig[3] = sig[3] * ((1 + \bodySelect.kr(0.0)) / 2);
        
        Out.ar(out, sig * \striVol.kr(0.2))
    }).add;

    // SynthDef for body or resonator
    SynthDef(\body, {
        arg in, stringsFree = 0;
        var sig;
        
        sig = In.ar(in, 2);
        sig = Resonator.ar(
            sig, \bodFreq.kr(100), \position.kr(0.001), \resolution.kr(24),
            \bodStruct.kr(0.5), \bodBright.kr(0.5), \bodDamp.kr(0.5)
        );
        
        // detect silence in both left and right and if strings are inactive, free body
        FreeSelf.kr(DetectSilence.ar(sig + Impulse.ar(0)).product * stringsFree);

        Out.ar(0, sig * \bodVol.kr(0.2))
    }).add;


    // MIDI /////////////////////////////////////////////////////////////////////////
    

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
               // create new bodies if they don't exist
               ~bodyArr.do({
                    arg item, count;
                    if (item == nil, {
                        ~bodyArr.put(count, Synth(\body, [
                            \in, ~bodyBus.subBus(count * 2, 2).index,
                            // body parameters
                            \bodVol, bodVol[count],
                            \bodFreq, bodFreq[count],
                            \position, position[count],
                            \resolution, resolution[count],
                            \bodStruct, bodStruct[count],
                            \bodBright, bodBright[count],
                            \bodDamp, bodDamp[count],
                        ], ~bodiesGroup).onFree({~bodyArr[count] = nil}))
                    });
               });
                // create a new voice or retrigger if one already exist
                if(~keyArr[count] == nil, {
                    // create new string synthdef if it doesn't exist
                    ~keyArr.put(count, Synth(\string, [
                        // string parameters
                        \striFreq, striFreq[count],
                        \striVol, striVol[count],
                        \accent, accent[count],
                        \striStruct, striStruct[count],
                        \striBright, striBright[count],
                        \striDamp, striDamp[count],
                        // string panning depending on key
                        // 0 = -1, 10 = 1 for 11 strings 0-10
                        \panning, (count * 1/5) * - 1,

                        // determine which amount of each string goes into each body
                        \bodySelect, (count * 9/50) - 0.9,

                        \t_retrigger, 1,
                        \out, ~bodyBus.index,
                        \triggerMethod, 0,
                        \trigFreqBus, ~trigFreqBus
                    ], ~stringsGroup).onFree({
                        // function to run everytime one of the strings are freed
                        // reset the key index back to nil
                        ~keyArr[count] = nil;
                        // detect if all the strings are freed and perform the function
                        if(~keyArr.every({ |item| item == nil }) == true, {
                            // send message to bodies when all strings are free
                            ~bodyArr.do({ |item| item.set(\stringsFree, 1)})
                        })
                    }))
                }, {
                    // if it exist, change its parameter
                    ~keyArr.at(count).set(\t_retrigger, 1, \gate, 1)
                })
            };
        });
        // cycle modes
        if(note == 57){
            ~oscClient.sendMsg("/mode", "prev")
        };
        if(note == 62){
            ~oscClient.sendMsg("/mode", "next")
        };
        // transpose by cycle interval "pseudo-octave"
        if(note == 48){
            ~oscClient.sendMsg("/transposition/cycle_interval", "down")
        };
        if(note == 71){
            ~oscClient.sendMsg("/transposition/cycle_interval", "up")
        };
        // transpose by generator interval
        if(note == 59){
            ~oscClient.sendMsg("/transposition/generator_interval/transpositionDirection", "down")
        };
        if(note == 60){
            ~oscClient.sendMsg("/transposition/generator_interval/transpositionDirection", "up")
        };
        if(note == 52){
            ~oscClient.sendMsg("/transposition/generator_interval/degreeDirection", "down")
        };
        if(note == 67){
            ~oscClient.sendMsg("/transposition/generator_interval/degreeDirection", "up")
        };
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
            if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 20}, {
                ~trigFreqBus.value_(busVal + ((val - 64) * 0.1))
        })
        });
        ~trigFreqBus.getSynchronous.postln
    }, ccNum: 27)
)
