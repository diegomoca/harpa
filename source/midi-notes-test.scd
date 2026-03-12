{
    |harp|
    MIDIdef.noteOn((harp.midiNoteID).asSymbol, {
        Synth.new(\stringTest, [\t_trigger, harp.t_trigger, \trigFreq, harp.trigFreq, \freq, harp.testFreq])
    })
}
