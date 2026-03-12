{
    |self|
    MIDIdef.noteOn((self.midiNoteID).asSymbol, {
        Synth.new(\stringTest, [\t_trigger, self.t_trigger, \trigFreq, self.buses.trigFreq, \freq, self.testFreq])
    })
}
