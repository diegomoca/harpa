(
    s.makeWindow();
    s.window.alwaysOnTop_(true);
)

(
    SynthDef(\stringsBody, {
        |resFreq = 40, position = 0.01,
        resolution = 24, resoStruct = 0.5,
        resoBright = 0.5, resoDamp = 0.5|
        var t_trigger = NamedControl.kr(\t_trigger, [0, 0]);
        var infsustain = NamedControl.kr(\infsustain, [1, 1]);
        var strFreq = NamedControl.kr(\strFreq, [80, 80]);
        var accent = NamedControl.kr(\accent, [0.5, 0.5]);
        var striStruct = NamedControl.kr(\striStruct, [0.1, 0.1]);
        var striBright = NamedControl.kr(\striBright, [0.1, 0.1]);
        var striDamp = NamedControl.kr(\striDamp, [0.8, 0.8]);

        var strings, signal, out;

        strings = StringVoice.ar(
            trig: t_trigger,
            infsustain: infsustain,
            freq: strFreq,
            accent: accent,
            structure: striStruct,
            brightness: striBright,
            damping: striDamp
        );
        strings = Pan2.ar(strings, #[-1.0, 1.0], 1.0);

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

~stringsBody.setn(\t_trigger, [1, 1])

(
    ~stringBody.set(
        \t_trigger, 1,

        // string parameters
        \infsustain, 1,
        \strFreq, 80,
        \accent, 0.5,
        \striStruct, 0.1,
        \striBright, 0.5,
        \striDamp, 0.8,
        // body parameters
        \resFreq, 40,
        \position, 0.01,
        \resolution, 24,
        \resoStruct, 0.5,
        \resoBright, 0.5,
        \resoDamp, 0.5
    )
)


