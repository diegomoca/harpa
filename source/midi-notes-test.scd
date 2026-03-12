{
    // argument to receive dictionary from main event
    |self|
    // MIDIdef with individual key per instance
    MIDIdef.noteOn((self.midiNoteID).asSymbol, {
        // function to create new synth using parameters
        // *** FOR PARAMETERS FROM BUSES DICTIONARY USE: "self.buses" ***
        Synth.new(\stringTest, [\t_trigger, self.t_trigger, \trigFreq, self.buses.trigFreq, \freq, self.testFreq])
    })
}
