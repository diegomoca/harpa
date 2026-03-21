{
    // argument to receive dictionary from main event
    |self|
    // put MIDIdefs inside array so that keyboards can be freed with one variable
    [
        // MIDIDefs with individual key per instance to open and close string's ADSR
        // and to create a new body in case it doesn't exist
        MIDIdef.noteOn(("stringGateOpen" ++ self.synthID).asSymbol, {
            // arguments for velocity value and note number
            |vel, note|
            // function to create new synth using parameters
            // *** FOR PARAMETERS FROM BUSES DICTIONARY USE: "self.buses" ***
            // Synth.new(\string, [\t_trigger, self.t_trigger, \trigFreq, self.buses.trigFreq, \freq, self.init.striFreq[0]])

            // evaluate wether one of the keys activating a string was pressed
            self.init.stringKeys.do({
                // item is the item in the arrangement stringKeys and count is a counter
                arg item, count;
                if(note == item){
                    // create new bodies if they don't exist
                    self.init.bodyArr.do({
                        arg item, count;
                        if (item == nil, {
                            self.init.bodyArr.put(count, Synth(\body, [
                                \in, self.init.bodyBus.subBus(count * 2, 2).index,
                                // body parameters
                                \bodVol,        self.init.bodVol[count],
                                \bodFreq,       self.init.bodFreq[count],
                                \bodStructBus,  self.buses.bodStruct,
                                \bodBrightBus,  self.buses.bodBright,
                                \bodDamp,       self.init.bodDamp[count],
                                // bus used for fadeout on destroy
                                \fadeoutBus,    self.init.fadeoutBus,

                            ], self.init.bodiesGroup).onFree({
                                self.init.bodyArr[count] = nil;                                
                            }))
                        });
                    });
                    // create a new voice or retrigger if one already exist
                    if(self.init.keyArr[count] == nil, {
                        // create new string synthdef if it doesn't exist
                        self.init.keyArr.put(count, Synth(\string, [
                            // ADSR1 parameters
                            \attack1Bus,    self.buses.attack1,
                            \decay1Bus,     self.buses.decay1,
                            \sustain1Bus,   self.buses.sustain1,
                            \release1Bus,   self.buses.release1,
                            \curve1Bus,     self.buses.curve1,
                            // string parameters
                            \striFreq,      self.init.striFreq[count],
                            \striVolBus,    self.buses.striVol,
                            \accentBus,     self.buses.accent,
                            \striStructBus, self.buses.striStruct,
                            \striBrightBus, self.buses.striBright,
                            \striDampBus,   self.buses.striDamp,
                            // trigger parameters
                            \trigMethBus,   self.buses.trigMeth,
                            \trigFreqBus,   self.buses.trigFreq,
                            \trigDurBus,    self.buses.trigDur,

                            // "routing"
                            // string panning depending on key
                            // 0 = -1, 10 = 1 for 11 strings 0-10
                            \panning,       (count * 1/5) * - 1,
                            // determine which amount of each string goes into each body
                            \bodySelect,    (count * 9/50) - 0.9,

                            \t_retrigger,     1,
                            \out,           self.init.bodyBus.index,
                            \triggerMethod, 0,
                            
                            // bus used for fadeout on destroy
                            \fadeoutBus,    self.init.fadeoutBus,

                        ], self.init.stringsGroup).onFree({
                            // function to run everytime one of the strings are freed
                            // reset the key index back to nil
                            self.init.keyArr[count] = nil;
                            // detect if all the strings are freed and perform the function
                            if(self.init.keyArr.every({ |item| item == nil }) == true, {
                                // send message to bodies when all strings are free
                                self.init.bodyArr.do({
                                    |item| 
                                    if(item.notNil, {item.set(\stringsFree, 1)})
                                })
                            })
                        }))
                    }, {
                        // if it exist, change its parameter
                        self.init.keyArr.at(count).set(\t_retrigger, 1, \gate, 1)
                    })
                };
            });
            if(note == 57){
                ~pyOSCClient.sendMsg("/instruments/harpa" +/+ self.synthID.asString +/+ "freqs/mode", "prev")
            };
            if(note == 62){
                ~pyOSCClient.sendMsg("/instruments/harpa" +/+ self.synthID.asString +/+ "freqs/mode", "next")
            };
            // transpose by cycle interval "pseudo-octave"
            if(note == 48){
                ~pyOSCClient.sendMsg("/instruments/harpa" +/+ self.synthID.asString +/+ "freqs/transposition/cycle_interval", "down");
            };
            if(note == 71){
                ~pyOSCClient.sendMsg("/instruments/harpa" +/+ self.synthID.asString +/+ "freqs/transposition/cycle_interval", "up");
            };
            // transpose by generator interval
            if(note == 59){
                ~pyOSCClient.sendMsg("/instruments/harpa" +/+ self.synthID.asString +/+ "freqs/transposition/generator_interval/transpositionDirection", "down")
            };
            if(note == 60){
                ~pyOSCClient.sendMsg("/instruments/harpa" +/+ self.synthID.asString +/+ "freqs/transposition/generator_interval/transpositionDirection", "up")
            };
            if(note == 52){
                ~pyOSCClient.sendMsg("/instruments/harpa" +/+ self.synthID.asString +/+ "freqs/transposition/generator_interval/degreeDirection", "down")
            };
            if(note == 67){
                ~pyOSCClient.sendMsg("/instruments/harpa" +/+ self.synthID.asString +/+ "freqs/transposition/generator_interval/degreeDirection", "up")
            };
        }),

        MIDIdef.cc(("holdMode" ++ self.synthID).asSymbol, {
            |val, num|
            if(self.init.holdMode == 0, {self.init.holdMode = 1}, {self.init.holdMode = 0});
            [self.synthID, \holdMode, self.init.holdMode].postln
        }, ccNum: 64),

        MIDIdef.noteOff(("stringGateClose" ++ self.synthID).asSymbol, {
            |vel, note|
            self.init.stringKeys.do({
                arg item, count;
                if(note == item && {self.init.holdMode == 0},{
                    // operate only if synthdef exists
                    if(self.init.keyArr[count]!= nil, {
                        self.init.keyArr.at(count).set(\gate, 0)
                    })
                });
            })
        })
    ]
}
