{
    |self|
    MIDIdef.cc((self.midiCCID).asSymbol, {
        |val, num|
        self.buses.trigFreq.get({
            |busVal|
            if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 20}, {
                self.buses.trigFreq.value_(busVal + ((val - 64) * 0.1))
            })
        });
        self.buses.trigFreq.getSynchronous.postln
    })
}
