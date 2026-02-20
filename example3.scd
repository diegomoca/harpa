SynthDef(\test, {
    |trig = 1|
    var out;
    out = StringVoice.ar(trig);
    Out.ar(0, out)
}).add

Synth(\test)

(
Ndef(\string, {|pan=0, freq=100|
    var trig = Dust2.kr(7);
    var sig = StringVoice.ar(
        trig,
        infsustain: 0,
        freq:freq,
        accent: TRand.kr(0.0,1.0, trig),
        structure: TRand.kr(0.0,1.0, trig),
        brightness: TRand.kr(0.0,0.5, trig),
        damping: TRand.kr(0.1,0.5, trig),
    );

    Pan2.ar(sig * 0.5, pan)

}).play;
)

(
SynthDef(\string, {|out=0, pan=0, dur = 1, sustain=0, trig=1, amp=0.5, freq=100, accent=0.5, brightness=0.5, damping=0.5|
    var env = Env.perc.kr(gate: trig, timeScale:dur+sustain, doneAction: 2);
    var sig = StringVoice.ar(trig, infsustain: 1, freq: freq, accent: accent, brightness: brightness, damping: damping);

    sig = Pan2.ar(sig * 0.2, pan);
    Out.ar(out, env*sig * amp)
}).add;
)
(
Pdef('🍇',
    Pbind(
        \instrument, \string,
        \out, 0.0,
        \pan, Pwhite(-1.0,1.0),
        \dur, Pseg([1,5], 16, \lin, inf ) * 0.125,
        \sustain, Pwhite(0,0.25) * Pkey(\dur),
        \degree, Pstutter(3, Pwhite(0,7)),
        \octave, Pwhite(3,5),
        \accent, Pwhite(0.25,0.5),
        \brightness, Pwhite(0,0.25),
        \damping, Pwhite(0.25, 0.75),
    )
).play
)

//Define bow synthdef
(
SynthDef(\help_dwgbowed, { |out=0, freq=440, amp=0.5,force=1, gate=1,pos=0.07,c1=0.25,c3=31,pan=0|
    var vib = Gendy1.kr(1,1,1,1,0.1, 4,mul:0.003,add:1);
    var son = DWGBowedTor.ar(freq*vib, amp,force, gate,pos,0.1,c1,c3);
    son = DWGSoundBoard.ar(son);
    son = BPF.ar(son,118,1)+son;
    son = BPF.ar(son,430,1)+son;
    son = BPF.ar(son,490,1)+son;
    son = LPF.ar(son,6000);
    Out.ar(out, Pan2.ar(son * 0.005, pan));
}).add;
)

//Use it.
(

Pbind(
    \instrument, \help_dwgbowed,
    \dur , 3,
    \degree, Pseq([1,5,7+3], inf),
    \amp , Pseq([0.9,0.7,0.5],inf),
).play;
)

//Define pluck synthdef
(
SynthDef(\help_dwgplucked, { |out=0, freq=440, amp=0.5, gate=1, c3=20, pan=0|
    var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
    var inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env,gate);
    var son = DWGPlucked2.ar(freq, amp, gate,0.1,1,c3,inp);
    DetectSilence.ar(son, 0.001, doneAction:2);
    Out.ar(out, Pan2.ar(son * 0.05, pan));
}).add;
)

//Use it.
(
a = Scale.new(
    #[0, 1, 3, 5, 7, 8, 10],
    12,
    Tuning.new([0, 0.75, 2, 3.5, 4, 5, 6, 7, 8, 9, 10, 11]),
    "Custom"
);

Pbind(
    \instrument, \help_dwgplucked,
    \scale ,a,
    \delta , Pseq([1,0.5,0.5,0.5,0.5,0.5,0.5,1,0.5,0.5,1,1]*2,inf),
    \dur , 20,
    \degree, Pseq([1,8,8,8,8,8,8,-6,Prand([9,10,11],1),1,7,8]-8, inf),
    \amp , Pwhite(0.2,0.8),
    \c3 , Pseq([Pseq([1400],24),Pseq([300],24)],inf),
    \pan , Pwhite(-1,1),
).play;
)

(
x = {OteyPiano.ar(50,0.5)}.play;
)
x.free;

//Define piano synthdef
(
SynthDef(\help_oteypiano, { |out=0, freq=440,gate=1, amp=0.5,rho=1|
    var son = OteyPiano.ar(freq, amp, rho:rho)*EnvGen.ar(Env.asr(0,1,0.1),gate,doneAction:2);
    Out.ar(out, Pan2.ar(son * 0.1, LinLin.kr(freq,36.midicps,90.midicps,-0.75,0.75)));
}).add;
)

//Use it.
(
Pbind(
    \instrument, \help_oteypiano,
    \delta, 1,
    \dur, 3,
    \degree, Pseq([1,3,5], inf),
    \rho, Pwhite(0.1,3) //comment this line to get standard sound
).play;
)

//Define piano synthdef and soundboard
(
SynthDef(\help_oteypianostring, { |out=0, freq=440,gate=1, amp=0.5,rho=1|
    var son = OteyPianoStrings.ar(freq, amp, rho:rho)*EnvGen.ar(Env.asr(0,1,0.1),gate,doneAction:2);
    Out.ar(out, Pan2.ar(son * 1, LinLin.kr(freq,36.midicps,90.midicps,-0.75,0.75)));
}).add;

SynthDef(\piano_soundboard,{
    var audio = In.ar([20, 21], 2);
    audio = OteySoundBoard.ar(audio);
    Out.ar(0,audio);
}).add
)

//start soundboard effect
Synth.tail(1,\piano_soundboard);

//Use it.
(
Pbind(
    \instrument, \help_oteypianostring,
    \delta, 1,
    \dur, 3,
    \degree, Pseq([1,3,5], inf),
    \out, 20,
).play;
)




(
Ndef(\resonantsnare, { |pan=0|
    var trig = Impulse.kr(1);
    var snare = AnalogSnareDrum.ar(
        trig, decay: TRand.kr(0.1,0.5,trig)
    );

    var sig = Resonator.ar(
        input: snare,
        freq: TExpRand.kr(25.0,250.0,trig),
        position: 0.0,
        resolution: 24,
        structure: SinOsc.kr(0.01).unipolar,
        brightness: SinOsc.kr(0.01, 0.5*pi).unipolar * 0.5,
        damping: TRand.kr(0.2,0.8, trig)
    );

    // Limiter
    sig = sig.tanh;

    Pan2.ar(sig, pan);
}).play;
)

(
SynthDef(\resonator, {|out=0, pan=0, dur = 1, sustain=0, trig=1, amp=0.5, freq=100, structure=0.5, position=0.005, brightness=0.5, damping=0.5|
    var env = Env.perc.kr(gate: trig, timeScale:dur+sustain, doneAction: 2);
    var resolution = 24;
    var sig = Resonator.ar(PinkNoise.ar() * env, freq, position, resolution, structure, brightness, damping);

    sig = Pan2.ar(sig, pan);
    Out.ar(out, env*sig * amp)
}).add;
)
(
Pdef(':)',
    Pbind(
        \instrument, \resonator,
        \out, 0.0,
        \pan, Pwhite(-1.0,1.0),
        \dur, Pseg([1,5], 16, \lin, inf ) * 0.125,
        \sustain, Pwhite(0,0.25) * Pkey(\dur),
        \degree, Pstutter(3, Pwhite(0,7)),
        \octave, Pwhite(3,5),
        \structure, Pwhite(0.25,0.5),
        \brightness, Pwhite(0,0.25),
        \damping, Pwhite(0.25, 0.75),
    )
).play
)