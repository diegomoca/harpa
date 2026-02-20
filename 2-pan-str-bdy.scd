(
    s.makeWindow();
    s.window.alwaysOnTop_(true);
)

(
    SynthDef(\stringsBody, {
        |t_trigger = #[0, 0], infsustain = #[1, 1], strFreq = #[80, 80],
        accent = #[0.5, 0.5], striStruct = #[0.1, 0.1], striBright = #[0.1, 0.1],
        striDamp = #[0.8, 0.8], resFreq = 40, position = 0.01,
        resolution = 24, resoStruct = 0.5,
        resoBright = 0.5, resoDamp = 0.5|

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

~stringsBody.setn(\t_trigger, [0, 1])

(
    ~stringsBody.setn(
        // trigger
        \t_trigger, [1, 1],

        // string parameters
        \infsustain, 1!2,
        \strFreq, [80, 100],
        \accent, 0.5!2,
        \striStruct, 0.1!2,
        \striBright, 0.1!2,
        \striDamp, 0.8!2,
        // body parameters
        \resFreq, 40,
        \position, 0.01,
        \resolution, 24,
        \resoStruct, 0.5,
        \resoBright, 0.5,
        \resoDamp, 0.5
    )
)

~stringsBody = nil;
