
(
    var objs, massMatrix, connPointMatrix,
        excPointMatrix, readoutPointMatrix;

    objs = [
        Resonator1D(100, 0.3, 0.698698, 0.001515, 'CF'),
        Resonator1D(200, 0.1, 0.698698, 0.001515, 'CF')
    ];

    massMatrix = Array2D.fromArray(2, 1, [1, 1]);

    connPointMatrix = Array2D.fromArray(2, 1, [1, 1]);

    excPointMatrix = Array2D.fromArray(2, 3, [
        1.0.rand, 0, 1.0.rand,
        0, 1.0.rand, 1.0.rand
    ]);

    readoutPointMatrix = Array2D.fromArray(2, 6, [
        1.0.rand, 1.0.rand, 0, 0 , 1.0.rand, 1.0.rand,
        0, 0, 1.0.rand, 1.0.rand, 1.0.rand, 1.0.rand
    ]);

    ~network = ResonatorNetwork(
        objs, connPointMatrix, massMatrix,
        excPointMatrix, readoutPointMatrix
    ).calcModalData(
        gain:40.dbamp, maxFreq:16000, incl:"yynn", 
        pathname: "/Users/diegomoca/Documents/01_proyectos/harpa/modalData.json"
    )
)

(
    var sr = 44100 ? s.sampleRate;
    [
        ~network.modalData["eigenvaluesPolar"]
        ["angle"]*sr/2pi, 6.91/(1.0 -
            ~network.modalData["eigenvaluesPolar"]["radius"] * sr)
    ].flop
    do: _.postln;
)

(
    s.waitForBoot({
        ~makeResonatorSynthDef = {
            arg inA1, inA2, inB1, inB2, synthDefName;

            inA1.postln;

            SynthDef(synthDefName, {
                arg inBus, outBus = 0, inputGain = 1,
                outputGain = 1, dryWet = 1;

                var input, output, a1, a2, b1, b2;

                a1 = \a1.ir(inA1);
                a2 = \a2.ir(inA2);
                b1 = \b1.ir(inB1);
                b2 = \b2.ir(inB2);
                
                input = In.ar(inBus) * inputGain;
                
                output = SOS.ar(
                    input, 0, a1, a2, b1, b2
                ).sum * outputGain;
                
                Out.ar(
                    outBus, (1 - dryWet) * input + (dryWet * output)
                )  
            }).add
        };

        SynthDef(\strike, {
            arg outBus = 0, lpFreq = 12000,
            strikeFreq = 1;

            var signal = LPF.ar(Impulse.ar(strikeFreq), lpFreq);

            Out.ar(outBus, signal)
        }).add
    })
)

(
    ~makeResonatorSynthDef.(
        ~network.modalData["biquadCoefs"]["a1"][0][0],
        ~network.modalData["biquadCoefs"]["a2"][0][0],
        ~network.modalData["biquadCoefs"]["b1"].neg,
        ~network.modalData["biquadCoefs"]["b2"].neg,
        \string1_left
    );

    ~makeResonatorSynthDef.(
        ~network.modalData["biquadCoefs"]["a1"][1][0],
        ~network.modalData["biquadCoefs"]["a2"][1][0],
        ~network.modalData["biquadCoefs"]["b1"].neg,
        ~network.modalData["biquadCoefs"]["b2"].neg,
        \string1_right
    )
)

(
    s.makeBundle(nil,{
        x = Synth(
            \string1_left,
            [\inBus, 10, \outBus, 0, \outputGain, 5],
            1, \addToTail
        );
        y = Synth(
            \string1_right,
            [\inBus, 10, \outBus, 1, \outputGain, 5],
            1, \addToTail
        );
        z = Synth(
            \strike,
            [\outBus, 10, \lpFreq, 8000], 1, \addToHead
        )
    })
)

x.free;
y.free;
z.free;

(
    ~makeResonatorSynthDef.(
        ~network.modalData["biquadCoefs"]["a1"][2][0],
        ~network.modalData["biquadCoefs"]["a2"][2][0],
        ~network.modalData["biquadCoefs"]["b1"].neg,
        ~network.modalData["biquadCoefs"]["b2"].neg,
        \string2_left
    );

    ~makeResonatorSynthDef.(
        ~network.modalData["biquadCoefs"]["a1"][3][0],
        ~network.modalData["biquadCoefs"]["a2"][3][0],
        ~network.modalData["biquadCoefs"]["b1"].neg,
        ~network.modalData["biquadCoefs"]["b2"].neg,
        \string2_right
    );
)

(
    s.makeBundle(nil, {
        x = Synth(
            \string2_left,
            [\inBus, 10, \outBus, 0, \outputGain, 10],
            1, \addToTail
        );
        y = Synth(
            \string2_right,
            [\inBus, 10, \outBus, 1, \outputGain, 10],
            1, \addToTail
        );
        z = Synth(
            \strike, [\outBus, 10, \lpFreq, 8000],
            1, \addToHead
        )
    })
)
