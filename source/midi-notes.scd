// define midi notes to play strings
var stringKeys = [49, 51, 54, 56, 58, 61, 63, 66, 68, 70, 72];

// initial string parameters
// tuning (traditional pentatonic scale)
var striFreq = [100, 112.5, 126.5625, 150.0, 168.75, 200.0, 225.0, 253.125, 300.0, 337.5, 400.0],
    // initial body parameters
    bodVol = [1, 0.5],
    bodFreq = [12.5, 400],
    bodDamp = [0.8, 0.2],
    holdMode = 0;

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
                        \bodStructBus, ~bodStructBus,
                        \bodBrightBus, ~bodBrightBus,
                        \bodDamp, bodDamp[count],
                    ], ~bodiesGroup).onFree({~bodyArr[count] = nil}))
                });
            });
            // create a new voice or retrigger if one already exist
            if(~keyArr[count] == nil, {
                // create new string synthdef if it doesn't exist
                ~keyArr.put(count, Synth(\string, [
                    // ADSR1 parameters
                    \attack1Bus, ~attack1Bus,
                    \decay1Bus, ~decay1Bus,
                    \sustain1Bus, ~sustain1Bus,
                    \release1Bus, ~release1Bus,
                    \curve1Bus, ~curve1Bus,
                    // string parameters
                    \striFreq, striFreq[count],
                    \striVolBus, ~striVolBus,
                    \accentBus, ~accentBus,
                    \striStructBus, ~striStructBus,
                    \striBrightBus, ~striBrightBus,
                    \striDampBus, ~striDampBus,
                    // trigger parameters
                    \trigFreqBus, ~trigFreqBus,
                    \trigDurBus, ~trigDurBus,

                    // "routing"
                    // string panning depending on key
                    // 0 = -1, 10 = 1 for 11 strings 0-10
                    \panning, (count * 1/5) * - 1,
                    // determine which amount of each string goes into each body
                    \bodySelect, (count * 9/50) - 0.9,

                    \t_retrigger, 1,
                    \out, ~bodyBus.index,
                    \triggerMethod, 0,

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

MIDIdef.cc(\holdMode, {
    |val, num|
    if(holdMode == 0, {holdMode = 1}, {holdMode = 0});
    holdMode.postln
}, ccNum: 64);

MIDIdef.noteOff(\stringGateClose, {
    |vel, note|
    stringKeys.do({
        arg item, count;
        if(note == item && {holdMode == 0},{
            // operate only if synthdef exists
            if(~keyArr[count]!= nil, {
                ~keyArr.at(count).set(\gate, 0)
            })
        });
    })
});
