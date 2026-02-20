(
    s.makeWindow();
    s.window.alwaysOnTop_(true);
)

s.latency = nil;

// create SynthDef
(
    SynthDef(\stringsBody, {
        |resFreq = 40, position = 0.01,
        resolution = 24, resoStruct = 0.5,
        resoBright = 0.5, resoDamp = 0.5|
        var t_trigger = NamedControl.kr(\t_trigger, 0!10);
        var infsustain = NamedControl.kr(\infsustain, 1!10);
        var strFreq = NamedControl.kr(\strFreq, 80!10);
        var accent = NamedControl.kr(\accent, 0.5!10);
        var striStruct = NamedControl.kr(\striStruct, 0.1!10);
        var striBright = NamedControl.kr(\striBright, 0.1!10);
        var striDamp = NamedControl.kr(\striDamp, 0.8!10);

        var strings, signal, out;
        var panning = List.new;
        var index = 0;

        strings = StringVoice.ar(
            trig: t_trigger,
            infsustain: infsustain,
            freq: strFreq,
            accent: accent,
            structure: striStruct,
            brightness: striBright,
            damping: striDamp
        );
        
        10.do({
            panning.insert(
                index,
                (index * 2 / 9) - 1
            );
            index = index + 1
        });
        index = 0;
        strings = Pan2.ar(strings, panning.asArray, 1.0);

        out = Resonator.ar(
            input: strings,
            freq: resFreq,
            position: position,
            resolution: resolution,
            structure: resoStruct,
            brightness: resoBright,
            damping: resoDamp
        );

        Out.ar(0, out)
    }).add;
    ~stringsBody = Synth(\stringsBody);
)

// set parameters
(
    ~stringsBody.setn(
        // string parameters
        \infsustain, 1!10,
        \strFreq, [100, 114.286, 130.612, 153.125, 175.0, 200, 228.571, 261.224, 306.25, 350],
        \accent, 0.5!10,
        \striStruct, 0.1!10,
        \striBright, 0.1!10,
        \striDamp, 0.8!10,
        // body parameters
        \resFreq, 40,
        \position, 0.01,
        \resolution, 24,
        \resoStruct, 0.5,
        \resoBright, 0.5,
        \resoDamp, 0.5
    )
)

// initialize keyboard control
(
    var stringPicker = Array.new(10);
    stringPicker = 0!10;

    k = KeyPlayer(\stringNumber);
    "1234vb7890".do{
        |char|
        k.put(char, {
            |char|
            if(char == $1){
                stringPicker.put(0, 1);
                ~stringsBody.setn(\t_trigger, stringPicker);
                stringPicker = 0!10;
            };
            if(char == $2){
                stringPicker.put(1, 1);
                ~stringsBody.setn(\t_trigger, stringPicker);
                stringPicker = 0!10
            };
            if(char == $3){
                stringPicker.put(2, 1);
                ~stringsBody.setn(\t_trigger, stringPicker);
                stringPicker = 0!10
            };
            if(char == $4){
                stringPicker.put(3, 1);
                ~stringsBody.setn(\t_trigger, stringPicker);
                stringPicker = 0!10
            };
            if(char == $v){
                stringPicker.put(4, 1);
                ~stringsBody.setn(\t_trigger, stringPicker);
                stringPicker = 0!10
            };
            if(char == $b){
                stringPicker.put(5, 1);
                ~stringsBody.setn(\t_trigger, stringPicker);
                stringPicker = 0!10
            };
            if(char == $7){
                stringPicker.put(6, 1);
                ~stringsBody.setn(\t_trigger, stringPicker);
                stringPicker = 0!10
            };
            if(char == $8){
                stringPicker.put(7, 1);
                ~stringsBody.setn(\t_trigger, stringPicker);
                stringPicker = 0!10
            };
            if(char == $9){
                stringPicker.put(8, 1);
                ~stringsBody.setn(\t_trigger, stringPicker);
                stringPicker = 0!10
            };
            if(char == $0){
                stringPicker.put(9, 1);
                ~stringsBody.setn(\t_trigger, stringPicker);
                stringPicker = 0!10
            };
        })
    };
    g = KeyPlayerGui(k);
)

~stringsBody = nil;
