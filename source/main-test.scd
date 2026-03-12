var keyboardFunction = Require("midi-notes-test"),
    ccFunction = Require("midi-cc-test"),
    busList = Require("control-buses-test");

Require("synthdefs-test");

~makeHarpa = {
    |testFreq|
    var midiNoteID = UniqueID.next;
    var midiCCID = UniqueID.next;
    (
        testFreq: testFreq,
        midiNoteID: midiNoteID,
        midiCCID: midiCCID,
        t_trigger: 1,
        buses: busList.value,
        keyboardActive: nil,
        ccActive: nil,

        keyboardActivate: {
            |self|
            self.keyboardActive = keyboardFunction.value(self)
        },

        ccActivate: {
            |self|
            self.ccActive = ccFunction.value(self)
        },

        keyboardDeactivate: { |self| self.keyboardActive.free},
        ccDeactivate: { |self| self.ccActive.free}
    )
};

