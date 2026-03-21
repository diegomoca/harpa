// load required files outside fuction so that path stays relative
// using the "Require" quark so that functions load properly
var initialization      = Require("initialization-test"),
    busList             = Require("control-buses-test"),
    keyboardFunction    = Require("midi-notes-test"),
    ccFunction          = Require("midi-cc-test");

// load SynthDefs
Require("synthdefs-test");

// pseudo class to create multiple instances of the instrument
~makeHarpa = {
    // values that can be set at initialization and get passed to the event
    |id|
    // create unique IDs for each instance of synthesizer
    // for individual MIDIdefs
    var synthID = UniqueID.next.asSymbol;
    if(id.notNil, {synthID = id.asSymbol});
    (
        // function from loaded file containing dictionary
        // with initialization values
        init: initialization.value,
        // function from the loaded file containing buses dictionary
        buses: busList.value,
        // trigger for individual instances
        t_trigger: 1,

        // unique ID for any instance of the synth
        synthID: synthID,
        // variables to store MIDIdefs and be able to free them
        keyboardActive: nil,
        ccActive: nil,

        // pseudo method to connect midi keyboard to instrument instances
        keyboardActivate: {
            |self|
            self.keyboardActive = keyboardFunction.value(self)
        },

        // pseudo method to connect cc controls to instrument instances
        ccActivate: {
            |self|
            self.ccActive = ccFunction.value(self)
        },

        // pseudo methods to disconnect midi controls from instrument instances
        keyboardDeactivate: { |self| self.keyboardActive.do{ |item| item.free } },
        ccDeactivate: { |self| self.ccActive.do{ |item| item.free } },

        // remove created groups when destroy method gets called
        removeGroups: { |self| self.init.stringsGroup.free; self.init.bodiesGroup.free},

        // fadeout synths and remove them
        removeSynths: {
            |self|
            var line = {
                Out.kr(
                    self.init.fadeoutBus.index,
                    Line.kr(1.0, 0.0, 0.5, doneAction: 2)
                )
            }.play;
            line.onFree({
                // close all string gates so that bodies can close
                self.init.keyArr.do { |item| item.notNil.if { item.set(\gate, 0) } };

                 // one-shot watcher: runs only for this destroy call
                Routine({
                    while({ self.init.bodyArr.any({ |item| item.notNil }) }, {
                        0.02.wait; // non-blocking polling
                    });
                    self.removeGroups;
                }).play;
            });
        }
    )
};

