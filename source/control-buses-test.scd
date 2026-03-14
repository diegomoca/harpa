// event inside a function working as a dictionary for control buses
{(
    // ADSR1 parameters
    attack1:    Bus.control(s, 1).value_(0.01),
    decay1:     Bus.control(s, 1).value_(0.3),
    sustain1:   Bus.control(s, 1).value_(0.5),
    release1:   Bus.control(s, 1).value_(1),
    curve1:     Bus.control(s, 1).value_(-4),
    // trigger parameters
    trigFreq:   Bus.control(s, 1).value_(0),
    trigDur:    Bus.control(s, 1).value_(0.01),
    trigMeth:   Bus.control(s, 1).value_(0),
    // string parameters
    striVol:    Bus.control(s, 1).value_(0.2),
    accent:     Bus.control(s, 1).value_(0.5),
    striStruct: Bus.control(s, 1).value_(0.1),
    striBright: Bus.control(s, 1).value_(0.2),
    striDamp:   Bus.control(s, 1).value_(0.8),
    // body parameters
    bodStruct:  Bus.control(s, 1).value_(0.2),
    bodBright:  Bus.control(s, 1).value_(0)
)}
