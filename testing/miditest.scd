MIDIClient.init
MIDIIn.connectAll
MIDIFunc.trace(false)

(
    MIDIClient.init
    MIDIIn.connectAll

    MIDIdef.noteOn(\noteOn, {
        |val, num|
        var stringKeys = [49, 51, 54, 56, 58, 61, 63, 66, 68, 70, 62];

        num.postln;

            // string triggers
            stringKeys.do({
                arg item, count;
                if(num == item){
                    stringPicker.put(count, 1);
                    ~stringsBody.setn(\t_trigger, stringPicker);
                    stringPicker = 0!11;
                };
            });
    })
)
MIDIdef.freeAll
