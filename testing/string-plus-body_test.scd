(
    s.makeWindow();
    s.window.alwaysOnTop_(true);
)

(
    SynthDef.new(\stringBody, {
        |t_trigger = 0, infsustain = 1, strFreq = 80,
        accent = 0.5, striStruct = 0.1, striBright = 0.5,
        striDamp = 0.8, resFreq = 40, position = 0.01,
        resolution = 24, resoStruct = 0.5,
        resoBright = 0.5, resoDamp = 0.5|
        var string, signal, out;

        string = StringVoice.ar(
            trig: t_trigger,
            infsustain: infsustain,
            freq: strFreq,
            accent: accent,
            structure: striStruct,
            brightness: striBright,
            damping: striDamp
        );
        signal = Resonator.ar(
            input: string,
            freq: resFreq,
            position: position,
            resolution: resolution,
            structure: resoStruct,
            brightness: resoBright,
            damping: resoDamp
        );
        
        out = Pan2.ar(signal, 0.0, 1.0);
        Out.ar(0, out)
    }).add;
    ~stringBody = Synth.new(\stringBody);
)

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

