SynthDef(\stringTest, {
    var sig, impulse;
    var trigFreq = In.kr(\trigFreq.kr(2), 1);

    impulse = HPZ1.kr(
        Phasor.kr(\t_trigger.kr(0), trigFreq * ControlDur.ir, 0, 1, 0)
    ) < 0;

    sig = StringVoice.ar(\t_trigger.kr(0) + impulse, 1, \freq.kr(300));
    Out.ar(0, sig)
}).add;
