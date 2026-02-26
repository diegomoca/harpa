(
    s.makeWindow();
    s.window.alwaysOnTop_(true);
)

s.boot

s.latency = nil;

// set up osc client
~oscClient = NetAddr("localhost", 57121);


~oscClient.disconnect

// create SynthDef
(
    SynthDef(\stringsBody, {
        |resFreq = 40, position = 0.01,
        resolution = 24, resoStruct = 0.5,
        resoBright = 0.5, resoDamp = 0.5|
        var t_trigger = NamedControl.kr(\t_trigger, 0!11);
        var infsustain = NamedControl.kr(\infsustain, 1!11);
        var strFreq = NamedControl.kr(\strFreq, 80!11);
        var accent = NamedControl.kr(\accent, 0.5!11);
        var striStruct = NamedControl.kr(\striStruct, 0.1!11);
        var striBright = NamedControl.kr(\striBright, 0.1!11);
        var striDamp = NamedControl.kr(\striDamp, 0.8!11);

        var strings, signal, out, stringsPanned;
        var panning = List.new;
        var index = 0;

        if (t_trigger[10] == 1){
            strFreq[10].postln
        };

        strings = StringVoice.ar(
            trig: t_trigger,
            infsustain: infsustain,
            freq: strFreq,
            accent: accent,
            structure: striStruct,
            brightness: striBright,
            damping: striDamp
        );
        
        11.do({
            panning.insert(
                index,
                (index * 1 / 5) - 1
            );
            index = index + 1
        });
        index = 0;
        stringsPanned = Pan2.ar(strings, panning.asArray, 0.5).sum;

        out = Resonator.ar(
            input: strings,
            freq: resFreq,
            position: position,
            resolution: resolution,
            structure: resoStruct,
            brightness: resoBright,
            damping: resoDamp
        );

        Out.ar(0, stringsPanned)
    }).add;
    ~stringsBody = Synth(\stringsBody);
)

// set parameters
(
    ~stringsBody.setn(
        // string parameters
        \infsustain, 1!11,
        \strFreq, [
            100, 117.236328125, 133.984375,
            153.125, 175.0, 200, 234.47265625,
            267.96875, 306.25, 350.0, 400
        ],
        \accent, 0.5!11,
        \striStruct, 0.1!11,
        \striBright, 0.2!11,
        \striDamp, 0.8!11,
        // body parameters
        \resFreq, 6.25,
        \position, 0.5,
        \resolution, 50,
        \resoStruct, 0.2,
        \resoBright, 0,
        \resoDamp, 0.8
    )
)

// Receive frequencies from python
(   
    ~frequenciesRecieve = OSCFunc({
        |msg|
        postln(msg[1..]);
        ~stringsBody.setn(\strFreq, msg[1..]);
    }, '/freqs')
)

// initialize keyboard control
(
    var stringPicker = Array.new(11);
    stringPicker = 0!11;

    k = KeyPlayer(\stringNumber);
    "qwervbzuiohalskdjcn".do{
        |char|
        k.put(char, {
            |char|
            var stringKeys = [$q, $w, $e, $r, $v, $b, $z, $u, $i, $o, $h];
            ~generator_intervalTranspose = ["up", "up"];

            // string triggers
            stringKeys.do({
                arg item, count;
                if(char == item){
                    stringPicker.put(count, 1);
                    ~stringsBody.setn(\t_trigger, stringPicker);
                    stringPicker = 0!11;
                };
            });
            // cycle modes
            if(char == $d){
                ~oscClient.sendMsg("/mode", "prev")
            };
            if(char == $j){
                ~oscClient.sendMsg("/mode", "next")
            };
            // transpose by cycle interval "pseudo-octave"
            if(char == $a){
                ~oscClient.sendMsg("/transposition/cycle_interval", "down")
            };
            if(char == $l){
                ~oscClient.sendMsg("/transposition/cycle_interval", "up")
            };
            // transpose by generator interval
            if(char == $c){
                ~oscClient.sendMsg("/transposition/generator_interval/transpositionDirection", "down")
            };
            if(char == $n){
                ~oscClient.sendMsg("/transposition/generator_interval/transpositionDirection", "up")
            };
            if(char == $s){
                ~oscClient.sendMsg("/transposition/generator_interval/degreeDirection", "down")
            };
            if(char == $k){
                ~oscClient.sendMsg("/transposition/generator_interval/degreeDirection", "up")
            };
        })
    };
    g = KeyPlayerGui(k);
)
