// SynthDef for individual string
SynthDef(\string, {
    |out|
    var sig, ampEnv, trigger, impulse;

    // define busses
    // in for control bus binded to parameter trigger frequency
    var attack1 = In.kr(\attack1Bus.kr(0.01), 1),
    // ADSR1 parameters busses
        decay1 = In.kr(\decay1Bus.kr(0.3), 1),
        sustain1 = In.kr(\sustain1Bus.kr(0.5), 1),
        release1 = In.kr(\release1Bus.kr(1), 1),
        curve1 = In.kr(\curve1Bus.kr(-4), 1),
    // trigger parameter busses
        trigFreq = In.kr(\trigFreqBus.kr(0), 1),
        trigDur = In.kr(\trigDurBus.kr(0.01), 1),
        trigMeth = In.kr(\trigMethBus.kr(0), 1),
    // string parameter busses
        volume = In.kr(\striVolBus.kr(0.2), 1) * In.kr(\fadeoutBus.kr(1.0), 1),
        accent = In.kr(\accentBus.kr(0.5), 1),
        structure = In.kr(\striStructBus.kr(0.1), 1),
        brightness = In.kr(\striBrightBus.kr(0.2), 1),
        damping = In.kr(\striDampBus.kr(0.8), 1);

    // adsr envelope
    ampEnv = Env.adsr(attack1, decay1, sustain1, release1, curve: curve1);

    // creation of phasor which can be retriggered and convertion to impulses
    // for better implementation inside UGen Trig
    impulse = HPZ1.kr(
        Phasor.kr(\t_retrigger.kr(0), trigFreq * ControlDur.ir, 0, 1, 0)
    ) < 0;

    // actual trigger of the string with two possible activation modes
    // constant impulses or random impulses
    trigger = Trig.kr(Select.kr(trigMeth, [
        impulse + \t_retrigger.kr,
        Dust.kr(trigFreq)
    ]), trigDur);
    
    // actual string synthesizer
    sig = StringVoice.ar(
        trigger, 1, \striFreq.kr(300), accent,
        structure, brightness, damping
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
    
    Out.ar(out, sig * volume)
}).add;

// SynthDef for body or resonator
SynthDef(\body, {
    arg in, stringsFree = 0;
    var sig;

    // define busses
    var structure = In.kr(\bodStructBus.kr(0.2), 1),
        brightness = In.kr(\bodBrightBus.kr(0), 1);

    sig = In.ar(in, 2);
    sig = Resonator.ar(
        sig, \bodFreq.kr(100), 0.01, 24,
        structure, brightness, \bodDamp.kr(0.5)
    );
    
    // detect silence in both left and right and if strings are inactive, free body
    FreeSelf.kr(DetectSilence.ar(sig + Impulse.ar(0)).product * stringsFree);

    Out.ar(0, sig * \bodVol.kr(0.2) * In.kr(\fadeoutBus.kr(1.0), 1))
}).add;
