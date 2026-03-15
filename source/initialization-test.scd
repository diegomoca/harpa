{
    // declare variable stringsGroup outside event so that bodiesGroup can access it
    var stringsGroup = Group.new;
    (   
        // audio bus to send string to 2 stereo bodies
        bodyBus: Bus.audio(s, 4),

        // bus to fadeout everything
        fadeoutBus: Bus.control(s, 1).value_(1.0),

        // create a group for strings and one for bodies
        // so that the bodies are always under the strings on the server
        stringsGroup: stringsGroup,
        bodiesGroup: Group.after(stringsGroup),

        // array to index voices (number of elements: number of "strings")
        keyArr: nil!11,

        // array to index ressonators (number of elements: number of "bodies")
        bodyArr: nil!2,
            
        // define midi notes to play strings
        stringKeys: [49, 51, 54, 56, 58, 61, 63, 66, 68, 70, 72],

        // *** INITIAL PARAMETERS ***
        // initial string parameters
        // tuning (traditional pentatonic scale)
        striFreq: [100, 112.5, 126.5625, 150.0, 168.75, 200.0, 225.0, 253.125, 300.0, 337.5, 400.0],
        // initial body parameters
        bodVol: [1, 0.5],
        bodFreq: [12.5, 400],
        bodDamp: [0.8, 0.2],
        // TODO turn hold mode back to 0
        holdMode: 1,
    )
}
