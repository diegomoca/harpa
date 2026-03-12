{
    // argument to receive dictionary from main event
    |self|
    // MIDIdef with individual key per instance
    MIDIdef.cc((self.midiCCID).asSymbol, {
        // arguments to receive value and cc number
        |val, num|

        // functions change synth parameters
        // *** FOR PARAMETERS FROM BUSES DICTIONARY USE: "self.buses" ***
        // get current value from bus
        self.buses.trigFreq.get({
            // argument containing current bus value
            |busVal|
            // conditional for value within range
            if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 20}, {
                // change bus value
                self.buses.trigFreq.value_(busVal + ((val - 64) * 0.1))
            })
        });
        // post bus value as it changes
        self.buses.trigFreq.getSynchronous.postln
    })
}
