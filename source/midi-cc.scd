{
    // argument to receive dictionary from main event
    |self|
    [
        // MIDIdef with individual key per instance
        MIDIdef.cc(("trigFreq" ++ self.synthID).asSymbol, {
            // arguments to receive value and cc number
            |val, num|

            if(val != 64, {

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
            // post parameter name and bus value as it changes
            [self.synthID, \trigFreq, self.buses.trigFreq.getSynchronous].postln
            });
        }, ccNum: 20),

        // MIDIdef for parameter trigger duration
        MIDIdef.cc(("trigDur" ++ self.synthID).asSymbol, {
            |val, num|
            if(val != 64, {
            self.buses.trigDur.get({
                |busVal|
                if(0 < (busVal + ((val - 64) * 0.01)), {self.buses.trigDur.value_(busVal + ((val - 64) * 0.01))})
            });
            [self.synthID, \trigDur, self.buses.trigDur.getSynchronous].postln
            });
        }, ccNum: 52),

        // MIDIdef for parameter trigger duration
        MIDIdef.cc(("trigMeth" ++ self.synthID).asSymbol, {
            |val, num|
            if(val != 64, {
            self.buses.trigMeth.get({
                |busVal|
                if(abs(val - 64) == 3, {
                    if(0 <= (busVal + ((val - 64)/3)) && {(busVal + ((val - 64)/3)) <= 1}, {
                        self.buses.trigMeth.value_(busVal + (val-64).sign)
                    })
                })
            });
            [self.synthID, \trigMeth, self.buses.trigMeth.getSynchronous].postln
            });
        }, ccNum: 59),

        MIDIdef.cc(("attack1" ++ self.synthID).asSymbol, {
            |val, num|
            if(val != 64, {
            self.buses.attack1.get({
                |busVal|
                if(0 < (busVal + ((val - 64) * 0.01)), {self.buses.attack1.value_(busVal + ((val - 64) * 0.01))})
            });
            [self.synthID, \attack1, self.buses.attack1.getSynchronous].postln
            });
        }, ccNum: 53),

        MIDIdef.cc(("decay1" ++ self.synthID).asSymbol, {
            |val, num|
            if(val != 64, {
            self.buses.decay1.get({
                |busVal|
                if(0 < (busVal + ((val - 64) * 0.01)), {self.buses.decay1.value_(busVal + ((val - 64) * 0.01))})
            });
            [self.synthID, \decay1, self.buses.decay1.getSynchronous].postln
            });
        }, ccNum: 54),

        MIDIdef.cc(("sustain1" ++ self.synthID).asSymbol, {
            |val, num|
            if(val != 64, {
            self.buses.sustain1.get({
                |busVal|
                if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 20}, {
                    self.buses.sustain1.value_(busVal + ((val - 64) * 0.01))
                })
            });
            [self.synthID, \sustain1, self.buses.sustain1.getSynchronous].postln
            });
        }, ccNum: 55),

        MIDIdef.cc(("release1" ++ self.synthID).asSymbol, {
            |val, num|
            if(val != 64, {
            self.buses.release1.get({
                |busVal|
                if(0 < (busVal + ((val - 64) * 0.01)), {self.buses.release1.value_(busVal + ((val - 64) * 0.01))})
            });
            [self.synthID, \release1, self.buses.release1.getSynchronous].postln
            });
        }, ccNum: 56),

        MIDIdef.cc(("curve1" ++ self.synthID).asSymbol, {
            |val, num|
            if(val != 64, {
            self.buses.curve1.get({
                |busVal|
                self.buses.curve1.value_(busVal + ((val - 64) * 0.01))
            });
            [self.synthID, \curve1, self.buses.curve1.getSynchronous].postln
            });
        }, ccNum: 57),

        MIDIdef.cc(("striVol" ++ self.synthID).asSymbol, {
            |val, num|
            if(val != 64, {
            self.buses.striVol.get({
                |busVal|
                if(-70 < (busVal.ampdb + ((val - 64) * 0.1)) && {(busVal.ampdb + ((val - 64) * 0.1)) < 0}, {
                    self.buses.striVol.value_((busVal.ampdb + ((val - 64) * 0.15)).dbamp)
                })
            });
            [self.synthID, \striVol, self.buses.striVol.getSynchronous.ampdb].postln
            });
        }, ccNum: 21),

        MIDIdef.cc(("accent" ++ self.synthID).asSymbol, {
            |val, num|
            if(val != 64, {
            self.buses.accent.get({
                |busVal|
                if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 1}, {
                    self.buses.accent.value_(busVal + ((val - 64) * 0.01))
                })
            });
            [self.synthID, \accent, self.buses.accent.getSynchronous].postln
            });
        }, ccNum: 22),

        MIDIdef.cc(("striStruct" ++ self.synthID).asSymbol, {
            |val, num|
            if(val != 64, {
            self.buses.striStruct.get({
                |busVal|
                if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 1}, {
                    self.buses.striStruct.value_(busVal + ((val - 64) * 0.01))
                })
            });
            [self.synthID, \striStruct, self.buses.striStruct.getSynchronous].postln
            });
        }, ccNum: 23),

        MIDIdef.cc(("striBright" ++ self.synthID).asSymbol, {
            |val, num|
            if(val != 64, {
            self.buses.striBright.get({
                |busVal|
                if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 1}, {
                    self.buses.striBright.value_(busVal + ((val - 64) * 0.01))
                })
            });
            [self.synthID, \striBright, self.buses.striBright.getSynchronous].postln
            });
        }, ccNum: 24),

        MIDIdef.cc(("striDamp" ++ self.synthID).asSymbol, {
            |val, num|
            if(val != 64, {
            self.buses.striDamp.get({
                |busVal|
                if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 1}, {
                    self.buses.striDamp.value_(busVal + ((val - 64) * 0.01))
                })
            });
            [self.synthID, \striDamp, self.buses.striDamp.getSynchronous].postln
            });
        }, ccNum: 25),

        MIDIdef.cc(("bodStruct" ++ self.synthID).asSymbol, {
            |val, num|
            if(val != 64, {
            self.buses.bodStruct.get({
                |busVal|
                if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 1}, {
                    self.buses.bodStruct.value_(busVal + ((val - 64) * 0.01))
                })
            });
            [self.synthID, \bodStruct, self.buses.bodStruct.getSynchronous].postln
            });
        }, ccNum: 26),

        MIDIdef.cc(("bodBright" ++ self.synthID).asSymbol, {
            |val, num|
            if(val != 64, {
            self.buses.bodBright.get({
                |busVal|
                if(0 < (busVal + ((val - 64) * 0.1)) && {(busVal + ((val - 64) * 0.1)) < 1}, {
                    self.buses.bodBright.value_(busVal + ((val - 64) * 0.01))
                })
            });
            [self.synthID, \bodBright, self.buses.bodBright.getSynchronous].postln
            });
        }, ccNum: 27)
    ]
}
