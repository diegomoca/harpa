"synthdefs-test.scd".loadRelative;

~makeHarpa = {
    |testFreq|
    var midiNoteID = UniqueID.next;
    var midiCCID = UniqueID.next;
    (
        testFreq: testFreq,
        midiNoteID: midiNoteID,
        midiCCID: midiCCID,
        t_trigger: 1,
        trigFreq: Bus.control(s, 1).set(2),
        keyboardActive: nil,
        ccActive: nil,

        keyboardActivate: {
            |self|
            self.keyboardActive = MIDIdef.noteOn((self.midiNoteID).asSymbol, {
                Synth.new(\stringTest, [\t_trigger, self.t_trigger, \trigFreq, self.trigFreq, \freq, self.testFreq])
            })
        },

        ccActivate: {
            |self|
            self.ccActive = MIDIdef.cc((self.midiCCID).asSymbol, {
                |val, num|
                self.trigFreq.get({
                    |busVal|
                    if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 20}, {
                        self.trigFreq.value_(busVal + ((val - 64) * 0.1))
                    })
                });
                self.trigFreq.getSynchronous.postln
            })
        },

        keyboardDeactivate: { |self| self.keyboardActive.free},
        ccDeactivate: { |self| self.ccActive.free}
    )
};

