// SYNTH FUNCTION //
a = {StringVoice.ar(1) * 1.5}
b = a.play
b.free

(
c = {
    arg modFreq = 0.5;
    var rand, mouseControl;

    mouseControl = MouseY.kr(20, 200);

    rand = SinOsc.kr(modFreq);

    StringVoice.ar(
        trig: 1,
        freq: mouseControl,
        accent: rand.range(0.9, 0.1)
    )
}.play
)
c.free

// SYNTHDEF 1 //
(
SynthDef.new(\singleString, {
    arg minFreq = 20, maxFreq = 500;
    var mouseControl, out;

    mouseControl = [MouseY.kr(minFreq, maxFreq), MouseX.kr(0.1, 0.9)];

    out = StringVoice.ar(
        trig: LFPulse.ar(mouseControl[0] * (4/28), 0, 0.01),
        freq: mouseControl[0],
        accent: mouseControl[1],
    );
    Out.ar(0, out)
}).add
)
a = Synth.new(\singleString)
a.free

// SYNTHDEF 2 Single Plucked String //
(
SynthDef.new("pluckTrigger", {
    arg t_trigger = 0, freq = 500, infsustain = 1,
    accent = 1, structure = 0.5, brightness = 0.5,
    damping = 0.5;
    var out;

    out = StringVoice.ar(
        trig: t_trigger,
        freq: freq,
        infsustain: infsustain,
        accent: accent,
        structure: structure,
        brightness: brightness,
        damping: damping
    );
    Out.ar(0, out)
}).add;
a = Synth.new(\pluckTrigger, ["freq", 100.0.rrand(500)])
)

(
a.set(
    \t_trigger, 1,

    \freq,70,
    \infsustain, 1,
    \accent, 0.8,
    \structure,0.3,
    \brightness, 0,
    \damping, 0.8
)
)

s.plotTree

a.free
s.freeAll

// NDef //
(
Ndef(\pluckedString, {
    |t_trigger = 0, freq = 500, infsustain = 1,
    accent = 1, structure = 0.5, brightness = 0.5,
    damping = 0.5|

    StringVoice.ar(
        trig: t_trigger,
        freq: freq,
        infsustain: infsustain,
        accent: accent,
        structure: structure,
        brightness: brightness,
        damping: damping
    )
}).play
)

Ndef(\pluckedString).set(\freq, 100)

Ndef(\pluckedString).gui






