// SynthDef for individual string
SynthDef(\string, {
    |out|
    var sig, env1, env2, trigger, retrigger, impulse;

    // define busses
    // ADSR1 parameters busses (gate: keyboard)
    var attack1 = In.kr(\attack1Bus.kr(0.01), 1),
        decay1 = In.kr(\decay1Bus.kr(0.3), 1),
        sustain1 = In.kr(\sustain1Bus.kr(0.5), 1),
        release1 = In.kr(\release1Bus.kr(1), 1),
        curve1 = In.kr(\curve1Bus.kr(-4), 1),
    // TODO add midi controls to ADSR2
    // ADSR2 parameters busses (gate: individual triggers)
        attack2 = In.kr(\attack2Bus.kr(0.1), 1),
        decay2 = In.kr(\decay2Bus.kr(0.3), 1),
        sustain2 = In.kr(\sustain2Bus.kr(0.5), 1),
        release2 = In.kr(\release2Bus.kr(1), 1),
        curve2 = In.kr(\curve2Bus.kr(0), 1),
    // trigger parameter busses
        trigFreq = In.kr(\trigFreqBus.kr(0), 1),
        trigDur = In.kr(\trigDurBus.kr(0.01), 1),
        trigMeth = In.kr(\trigMethBus.kr(0), 1),
    // string parameter busses
        volume = In.kr(\striVolBus.kr(0.5), 1) * In.kr(\fadeoutBus.kr(1.0), 1),
        accent = In.kr(\accentBus.kr(0.5), 1),
        structure = In.kr(\striStructBus.kr(0.1), 1),
        brightness = In.kr(\striBrightBus.kr(0.2), 1),
        damping = In.kr(\striDampBus.kr(0.8), 1);

    // adsr envelope 1
    env1 = Env.adsr(attack1, decay1, sustain1, release1, curve: curve1);
    // adsr envelope 2
    env2 = Env.adsr(attack2, decay2, sustain2, release2, curve: curve2);

    // creation of phasor which can be retriggered and convertion to impulses
    // for better implementation inside UGen Trig
    impulse = HPZ1.kr(
        Phasor.kr(\t_retrigger.kr(0), trigFreq * ControlDur.ir, 0, 1, 0)
    ) < 0;

    // actual trigger of the string with two possible activation modes
    // constant impulses or random impulses
    trigger = Trig.kr(Select.kr(trigMeth, [
        impulse,
        Dust.kr(trigFreq)
    ]), trigDur);
    retrigger = Trig.kr(\t_retrigger.kr, trigDur);
    
    // actual string synthesizer
    sig = StringVoice.ar(
        trigger, 1, \striFreq.kr(300), accent,
        structure, brightness, damping
    ) * EnvGen.kr(env1, \gate.kr(1), doneAction: 2) * EnvGen.kr(env2, trigger) + 
        StringVoice.ar(
            retrigger, 1, \striFreq.kr(300), accent,
            structure, brightness, damping
        ) * EnvGen.kr(env1, \gate.kr(1), doneAction: 2);

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
    
    Out.ar(out, sig * volume * 0.2)
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

    Out.ar(0, sig * 0.2 * \bodVol.kr(0.2) * In.kr(\fadeoutBus.kr(1.0), 1))
}).add;
